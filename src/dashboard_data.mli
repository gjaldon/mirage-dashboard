(* read the local json file describing repos of interest *)

val repos_from_json_to_json : string

val repo_list_from_json : string ->
  ((Core.Std.String.t * Core.Std.String.t) * Yojson.Safe.json list) list

val all_repos : repos_json_path:string -> (Core.Std.String.t * Core.Std.String.t) list
