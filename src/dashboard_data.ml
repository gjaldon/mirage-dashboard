open Core.Std

(*
 * utop example
 * * #require "yojson";;
*)

let repos_from_json =
    let repos_data = Yojson.Safe.from_file "data/repos.json" in
    let repo_list = repos_data |> Yojson.Safe.Util.to_list in
    let filtered = (
        `List
        (
            List.map
            ~f: (fun item ->
                Yojson.Safe.Util.member
                "repo"
                item)
            repo_list)) in
    Yojson.Safe.pretty_to_string filtered

