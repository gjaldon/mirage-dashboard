open Lwt

let get_info_for_repo ~token ~user ~repo =
  return (Github.Repo.info ~token ~user ~repo ())
