open Lwt

(**
   "id": 3009723,
    "tag_name": "",
    "target_commitish": "",
    "name": "",
    "body": "",
    "draft": false,
    "prerelease": false,
    "created_at": "2016-04-13T10:39:07Z",
    "published_at": "2016-04-13T10:41:24Z",
    "url": "https://api.github.com/...",
    "html_url": "https://github.com/...",
    "assets_url": "https://api.github.com/...",
    "upload_url": "https://uploads.github.com/..."
   *)

module G = Github
module M = Github.Monad

let get_releases_for_repo ~token ~user ~repo =
  return (G.Release.for_repo ~token ~user ~repo ())

let get_releases ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_releases_for_repo ~token ~user ~repo

let releases_to_list releases =
  G.(
    M.(
      run (
        Stream.to_list releases
      )
    )
  )

let strip_quotes str = 
  Str.global_replace (Str.regexp "\"") "" str

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
  (
    `Assoc [
      ("name", `String (strip_quotes (Yojson.Safe.to_string name)));
      ("published", `String (strip_quotes (Yojson.Safe.to_string published)));
      ("total", `Int total)
    ]
  )

let latest_relese releases =
  let total = List.length releases in
  if total > 0
  then release_values (List.hd releases) total
  else (
      `Assoc [
      ("name", `String "No release yet...");
      ("total", `Int 0)
      ]
    )

let get_current ~cookie_name ~user ~repo =
    get_releases
      ~cookie_name
      ~user
      ~repo
    >>= fun releases ->
    releases_to_list releases
    >>= fun releases_list ->
    return (latest_relese releases_list)
