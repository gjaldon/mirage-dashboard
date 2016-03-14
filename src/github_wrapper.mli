(* use a cookie from git jar to login to the gihub api*)

val login : cookie_name:string -> Github_j.auth Lwt.t
