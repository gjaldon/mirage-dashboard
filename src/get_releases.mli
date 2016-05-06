val get_current_release_or_tag :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Yojson.json Lwt.t

