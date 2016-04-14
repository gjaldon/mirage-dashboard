open Core.Std
open Lwt

let quite_pretty_json s = Yojson.Safe.pretty_to_string (Yojson.Safe.from_string s)

let first_str = function
  | hd :: _ -> hd
  | _ -> "{}"


let spec =
  let open Command.Spec in
  empty
    +> flag "-c" (required string) ~doc:"cookie github auth cookie, from git-jar"


let get_release_async ~cookie_name ~user ~repo =
    Github_wrapper.get_release
      ~cookie_name
      ~user
      ~repo
    >>= fun release ->
        Github_wrapper.release_to_list release
    >>= fun release_list ->
        Github_wrapper.release_strings release_list
    |> fun release_strings ->
        return (first_str release_strings)

let all_repos =
  Dashboard_data.repo_list_from_json "data/repos.json"
  |> (fun repo_list ->
      List.map
        ~f:(
          fun repo ->
            match repo with
            | ((u_name, r_name), tags) -> (u_name, r_name)
        )
        repo_list
    )

let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun cookie_name () ->
       Lwt_main.run (
         (
           Lwt_list.map_p
             (
               fun (user, repo) ->
                 get_release_async ~cookie_name ~user ~repo
             )
             all_repos
         )
         >>= fun r_list ->
         quite_pretty_json ("[" ^ (String.concat ~sep:", " r_list) ^ "]")
         |> Lwt_io.printf "%s\n"
       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
