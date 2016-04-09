open Core.Std

(*
 * utop example
 * * #require "yojson";;
*)

let repo_list_from_json file_path =
    let repos_data = Yojson.Safe.from_file file_path in
    let repo_list = repos_data |> Yojson.Safe.Util.to_list in
    (
        List.map
        ~f: (fun item -> (
                (
                    Yojson.Safe.Util.member
                    "repo"
                    item
                ),
                (
                    (
                        Yojson.Safe.Util.member
                        "tags"
                        item
                    ) |> Yojson.Safe.Util.to_list
                )
            )
        )
        repo_list
    )

let repos_from_json_to_json =
    let repos_data = Yojson.Safe.from_file "data/repos.json" in
    let repo_list = repos_data |> Yojson.Safe.Util.to_list in
    let filtered = (
        `List
        (List.map
        ~f: (fun item ->
            `Assoc [
                (
                    "repo",
                    (
                        Yojson.Safe.Util.member
                        "repo"
                        item
                    )
                );
                ("thing", `String "test")
            ])
        repo_list)) in
    Yojson.Safe.pretty_to_string filtered

