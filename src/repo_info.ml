open Lwt

let get_info repo_with_token =
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
