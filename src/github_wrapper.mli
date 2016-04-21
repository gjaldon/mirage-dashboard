(* use a cookie from git jar and retrieve release info from github api *)

val get_token :
  cookie_name:string ->
  Github.Token.t Lwt.t

val stream_to_list :
  'a Github.Stream.t ->
  'a list Lwt.t

val strip_quotes :
  string ->
  string
