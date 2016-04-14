open Lwt

module G = Github
module M = Github.Monad

let first_release_str = function
  | hd :: _ -> hd
  | _ -> "{\"tag_name\":\"no releases\"}"

let get_releases_for_repo ~token ~user ~repo =
  return (G.Release.for_repo ~token ~user ~repo ())

let get_releases ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_releases_for_repo ~token ~user ~repo

let release_to_list releases =
  G.(
    M.(
      run (
        Stream.to_list releases
      )
    )
  )

let release_strings release_list =
  List.map (
    fun rel ->
      Github_j.string_of_release rel
  ) release_list

let get_current ~cookie_name ~user ~repo =
    get_releases
      ~cookie_name
      ~user
      ~repo
    >>= fun release ->
        release_to_list release
    >>= fun release_list ->
        release_strings release_list
    |> fun release_strings ->
        return (first_release_str release_strings)
