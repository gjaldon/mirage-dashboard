(* use a cookie from git jar to login to the gihub api*)

val login :
  cookie_name:string ->
  Github_j.auth Lwt.t

(* use a cookie from git jar and retrieve release info from github api *)
val get_release :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Github_t.release Github.Stream.t Lwt.t 
