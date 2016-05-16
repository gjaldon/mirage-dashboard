open Lwt

(**
 * example branch values
 * name :str
 * commit : { sha: str, url: str}
*)

module G = Github

let get_branches_for_repo (repo_with_token:Github_wrapper.repo_with_token) =
  let (token, user, repo) = repo_with_token in
  return (G.Repo.branches ~token ~user ~repo ())

let extract_branch_name branch_str =
  let branch_data = Yojson.Safe.from_string branch_str in
  let name = (
    Yojson.Safe.Util.member
      "name"
      branch_data
  ) in (
    `String (Github_wrapper.strip_quotes (Yojson.Safe.to_string name))
  )

let get_branches (repo_with_token:Github_wrapper.repo_with_token) =
    get_branches_for_repo repo_with_token
    >>= fun stream ->
    Github_wrapper.stream_to_list stream
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
