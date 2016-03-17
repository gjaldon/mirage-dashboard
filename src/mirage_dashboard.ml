open Core.Std
open Lwt

let quite_pretty_json s = Yojson.Safe.pretty_to_string (Yojson.Safe.from_string s)

let spec =
  let open Command.Spec in
  empty
    +> flag "-c" (required string) ~doc:"cookie github auth cookie, from git-jar"

  let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun cookie_name () ->
       Lwt_main.run (
         Github_wrapper.login ~cookie_name
         >>= fun code ->
           Lwt_io.printf "%s\n" (quite_pretty_json (Github_j.string_of_auth code))
       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
