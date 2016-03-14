(* use a cookie from git jar to login to the gihub api*)

val login : cookie_name:string -> Github_j.auth Lwt.t

val get_release_for_repo : token:Github.Token.t -> Github_t.release Github.Stream.t Lwt.t 
