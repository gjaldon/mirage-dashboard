(* use a cookie from git jar and retrieve release info from github api *)

val get_token :
  cookie_name:string ->
  Github.Token.t Lwt.t
