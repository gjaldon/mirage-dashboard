(* use a cookie from git jar to login to the gihub api*)

val login :
  cookie_name:string ->
  Github_j.auth Lwt.t

(* use a cookie from git jar and retrieve release info from github api *)

val get_token :
  cookie_name:string ->
  Github.Token.t Lwt.t
