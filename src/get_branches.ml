open Lwt

module G = Github
module M = Github.Monad

let get_branches_for_repo ~token ~user ~repo =
  return (G.Repo.branches ~token ~user ~repo ())


let get_branches_stream ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_branches_for_repo ~token ~user ~repo

let stream_to_list stream =
  G.(
    M.(
      run (
        Stream.to_list stream
      )
    )
  )

let strip_quotes str = 
  Str.global_replace (Str.regexp "\"") "" str

let extract_branch_name branch_str =
  let branch_data = Yojson.Safe.from_string branch_str in
  let name = (
    Yojson.Safe.Util.member
      "name"
      branch_data
  ) in (
    `Assoc [
      ("name", `String (strip_quotes (Yojson.Safe.to_string name)))
    ]
  )

let get_branches ~cookie_name ~user ~repo =
    get_branches_stream
      ~cookie_name
      ~user
      ~repo
    >>= fun stream ->
    stream_to_list stream
    >>= fun branches_list ->
    return (
      `List (
        List.map
          (
            fun branch ->
              extract_branch_name
                (Github_j.string_of_repo_branch branch)
          )
          branches_list
      )
    )
