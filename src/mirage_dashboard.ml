open Core.Std
open Lwt

let get_item_at_index json_list index =
  match List.nth json_list index with
  | Some item -> item
  | None -> `String "not found"

let spec =
  let open Command.Spec in
  empty
  +> flag "-c" (required string) ~doc:"cookie github auth cookie, from git-jar"
  +> flag "-r" (required string) ~doc:"path to json file describing repositories"
  +> flag "-o" (required string) ~doc:"path to write json file output"

let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun cookie_name repos_json_path write_to_path () ->
       Lwt_main.run (
         (
           Github_wrapper.get_token cookie_name
           >>= fun token ->
           Lwt_list.map_s
             (
               fun (user, repo, tags) ->
                 (
                   let repo_with_token = (token, user, repo) in
                   Lwt_list.map_p
                     (
                       fun closure ->
                         closure
                     )
                     [
                       (Stats.Releases.get_current_release_or_tag repo_with_token);
                       (Stats.Branches.get_branches repo_with_token);
                       (Stats.Events.get_events_per_user repo_with_token);
                       (Stats.Repo_info.get_info repo_with_token)
                     ]
                 ) >>=
                 fun json_list ->
                 let current_release_or_tag = get_item_at_index json_list 0 in
                 let branches = get_item_at_index json_list 1 in
                 let events = get_item_at_index json_list 2 in
                 let info = get_item_at_index json_list 3 in
                 return (
                   `Assoc [
                     ("repo", `String repo);
                     ("user", `String user);
                     ("current_release_or_tag", current_release_or_tag);
                     ("branches", branches);
                     ("events", events);
                     ("tags", tags);
                     ("info", info)
                   ]
                 )

             )
             (Dashboard_data.all_repos ~repos_json_path)
         ) >>=
         fun r_list ->
         Yojson.to_file
           write_to_path
           (
             `Assoc [
               ("created_at", `Int (int_of_float (Unix.time())));
               ("repos", `List r_list)
             ]
           )
         |> fun () ->
         Lwt_io.printf "%s\n" "DONE!"
       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
