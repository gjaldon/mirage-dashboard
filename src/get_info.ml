open Lwt

let get_info_with_token ~token ~user ~repo =
  let open Github.Monad in
  run (
      Github.Repo.info ~token ~user ~repo ()
      >>~ fun info ->
      let descr = match info.repository_description with
        | Some descr -> descr
        | None -> ""
      in return (`String descr)
  )


let get_info_with_cookie ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  get_info_with_token ~token ~user ~repo

let get_info ~cookie_name ~user ~repo =
  get_info_with_cookie ~cookie_name ~user ~repo
