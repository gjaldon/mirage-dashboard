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
              let repo_path = (
                Yojson.Safe.Util.member
                  "repo"
                  item
              ) in
              let repo_path_string_with_quote = Yojson.Safe.to_string repo_path in
              let repo_path_string = (Str.global_replace (Str.regexp "\"") "" repo_path_string_with_quote) in
              let parts = (String.split ~on:'/' repo_path_string) in
              match parts with
              | user :: repo :: tl -> (user, repo)
              | _ -> ("mirage", "mirage")
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

let all_repos ~repos_json_path =
  repo_list_from_json repos_json_path
  |> (fun repo_list ->
      List.map
        ~f:fst
        repo_list
    )
