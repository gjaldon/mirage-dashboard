open Core.Std
open Lwt

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
                       (Get_branches.get_branches ~cookie_name ~user ~repo)
                     ]
                 ) >>=
                 fun json_list ->
                 let current_release = match List.nth json_list 0 with
                   | Some item -> item
                   | None -> `String "no releases found"
                 in
                 let branches = match List.nth json_list 1 with
                   | Some item -> item
                   | None -> `String "no branches found"
                 in
                 return (
                   `Assoc [
                     ("repo", `String repo);
                     ("user", `String user);
                     ("current_release", current_release);
                     ("branches", branches)
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
