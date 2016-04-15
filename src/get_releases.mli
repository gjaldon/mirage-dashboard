val get_current :
  cookie_name:string ->
  user:string ->
  repo:string ->
  [> `Assoc of (string * [> `Int of int | `String of string ]) list ] Lwt.t
