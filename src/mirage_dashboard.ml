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

let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun cookie_name repos_json_path () ->
       Lwt_main.run (
         (
           Lwt_list.map_p
             (
               fun (user, repo) ->
                 (
                   Lwt_list.map_p
                     (
                       fun closure ->
                         closure
                     )
                     [
                       (Get_releases.get_current ~cookie_name ~user ~repo);
                       (Get_branches.get_branches ~cookie_name ~user ~repo);
                       (Get_events.get_events_per_user ~cookie_name ~user ~repo)
                     ]
                 ) >>=
                 fun json_list ->
                 let current_release = get_item_at_index json_list 0 in
                 let branches = get_item_at_index json_list 1 in
                 let events = get_item_at_index json_list 2 in
                 return (
                   `Assoc [
                     ("repo", `String repo);
                     ("user", `String user);
                     ("current_release", current_release);
                     ("branches", branches);
                     ("events", events)
                   ]
                 )

             )
             (Dashboard_data.all_repos ~repos_json_path)
         ) >>=
         fun r_list ->
         Yojson.pretty_to_string (`List r_list)
         |> Lwt_io.printf "%s\n"
       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
