open Lwt

(**
 * example github release values
 * "id": 3009723,
 * "tag_name": "",
 * "target_commitish": "",
 * "name": "",
 * "body": "",
 * "draft": false,
 * "prerelease": false,
 * "created_at": "2016-04-13T10:39:07Z",
 * "published_at": "2016-04-13T10:41:24Z",
 * "url": "https://api.github.com/...",
 * "html_url": "https://github.com/...",
 * "assets_url": "https://api.github.com/...",
 * "upload_url": "https://uploads.github.com/..."
*)

module G = Github

let release_to_json detail =
  let (name, published_at, total, release_type) = detail in
  `Assoc [
    ("name", `String (name));
    ("published_at", `String published_at);
    ("of_total", `Int total);
    ("type", `String release_type)
  ]

(* RELEASES:*)

let get_releases_for_repo ~token ~user ~repo =
  return (G.Release.for_repo ~token ~user ~repo ())

let get_releases ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_releases_for_repo ~token ~user ~repo

let release_values release total =
  let release_str = Github_j.string_of_release release in
  let release_data = Yojson.Safe.from_string release_str in
  let name = (
    Yojson.Safe.Util.member
      "tag_name"
      release_data
  ) in
  let published = (
    Yojson.Safe.Util.member
      "published_at"
      release_data
  ) in
  release_to_json (
    (Github_wrapper.strip_quotes (Yojson.Safe.to_string name)),
    (Github_wrapper.strip_quotes (Yojson.Safe.to_string published)),
    total,
    "releases"
  )

let latest_relese releases total =
  release_values (List.hd releases) total

let get_current_release ~cookie_name ~user ~repo =
  get_releases
    ~cookie_name
    ~user
    ~repo
  >>= fun releases ->
  Github_wrapper.stream_to_list releases

(* TAGS: *)

let get_tags_for_repo ~token ~user ~repo =
  return (G.Repo.get_tags_and_times ~token ~user ~repo ())

let get_tags ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_tags_for_repo ~token ~user ~repo

let sort_tags tags =
  List.sort
    (
      fun a b ->
        let (_, created_a) = a in
        let (_, created_b) = b in
        if created_a < created_b then 1 else 0
    )
    tags

let latest_tag tags =
  let total = List.length tags in
  if total > 0
  then
    let sorted_tags = sort_tags tags in
    let (tag_name, created_at) = (List.hd sorted_tags) in
    release_to_json (
      tag_name,
      created_at,
      total,
      "tag"
    )
  else release_to_json ("No tag or release, yet...", "", 0, "releases or tags")

let get_latest_tag ~cookie_name ~user ~repo =
  catch
    (
      fun () ->
        get_tags
          ~cookie_name
          ~user
          ~repo
        >>= fun tags ->
        Github_wrapper.stream_to_list tags
        >>= fun tags_list ->
        return (latest_tag tags_list)
    )
    (
      function
      | _ -> return (release_to_json ("No tag or release, yet...", "", 0, "releases or tags"))
    )

(* combine the two, returning release if there is one, then tag, or none/default *)

let get_current_release_or_tag ~cookie_name ~user ~repo =
  get_current_release ~cookie_name ~user ~repo
  >>= fun releases_list ->
  let total = List.length releases_list in
  if total > 0
  then return (latest_relese releases_list total)
  else get_latest_tag ~cookie_name ~user ~repo
