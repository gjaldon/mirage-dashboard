(* use a cookie from git jar and retrieve release info from github api *)

type cookie_name = string
type user = string
type repo = string
type repo_with_cookie_name = (cookie_name * user * repo)
type repo_with_token = (Github.Token.t * user * repo)

val get_token :
  cookie_name:string ->
  Github.Token.t Lwt.t

val stream_to_list :
  'a Github.Stream.t ->
  'a list Lwt.t

val strip_quotes :
  string ->
  string
