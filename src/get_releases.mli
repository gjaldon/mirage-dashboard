val get_current :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Yojson.json Lwt.t

val get_latest_tag :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Yojson.json Lwt.t

