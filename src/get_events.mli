val get_events :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Yojson.json Lwt.t
