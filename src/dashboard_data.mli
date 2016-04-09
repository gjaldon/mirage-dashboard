(* read the local json file describing repos of interest *)

val repos_from_json_to_json : string

val repo_list_from_json : string ->
    (string * string list)
