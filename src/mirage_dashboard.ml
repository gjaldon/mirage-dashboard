open Core.Std
open Lwt

let quite_pretty_json s = Yojson.Safe.pretty_to_string (Yojson.Safe.from_string s)

let first_str = function
  | [] -> "{}"
  | hd :: _ -> hd


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
         Github_wrapper.get_release
           ~cookie_name
           ~user: "mirage"
           ~repo: "mirage"
         >>= fun release ->
         Github_wrapper.release_to_list release
         >>= fun release_list ->
         Github_wrapper.release_strings release_list
         |> fun release_strings ->
         Lwt_io.printf "%s\n" (quite_pretty_json (first_str release_strings))

       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
