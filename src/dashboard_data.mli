(* read the local json file describing repos of interest *)

val all_repos :
  repos_json_path:string ->
  (Core.Std.String.t * Core.Std.String.t * Yojson.json) list
