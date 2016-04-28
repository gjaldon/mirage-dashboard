val get_events_per_user :
  cookie_name:string ->
  user:string ->
  repo:string ->
  Yojson.json Lwt.t
