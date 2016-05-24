open Lwt

<<<<<<< HEAD:src/get_info.ml
let get_info repo_with_token =
=======
let get_info (repo_with_token:Github_wrapper.repo_with_token) =
>>>>>>> master:src/repo_info.ml
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
