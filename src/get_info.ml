open Lwt

let get_info_with_token (repo_with_token:Github_wrapper.repo_with_token) =
  let open Github.Monad in
  let (token, user, repo) = repo_with_token in
  run (
      Github.Repo.info ~token ~user ~repo ()
      >>~ fun info ->
      let descr = match info.Github_t.repository_description with
        | Some descr -> descr
        | None -> ""
      in return (`String descr)
  )

let get_info_with_cookie ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_info_with_token (token, user, repo)

let get_info ~cookie_name ~user ~repo =
  get_info_with_cookie ~cookie_name ~user ~repo
