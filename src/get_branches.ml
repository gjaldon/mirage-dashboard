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
              `String
                (Github_j.string_of_repo_branch branch)
          )
          branches_list
      )
    )
