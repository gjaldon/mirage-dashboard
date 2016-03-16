open Core.Std
open Lwt

let quite_pretty_json s = Yojson.Safe.pretty_to_string (Yojson.Safe.from_string s)

let name_of_release = Github_t.(function
    | { release_name=Some name } -> name
    | { release_name=None      } -> "NULL"
  )
let print_releases m =
    return (Stream.iter (fun m ->
        let open Github_t in
        let name = name_of_release m in
        eprintf "release %Ld: %s (%s)\n%!" m.release_id name m.release_created_at;
      ))

let is_release = function
  | Some lst -> lst
  | None -> []

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
       Lwt_main.run(
       Github_wrapper.get_release ~cookie_name ~user:"mirage" ~repo:"mirage"
       >>= fun release ->
       return (Github.Stream.to_list release)
       >>= fun rel_list ->
           Lwt_io.printf "%s\n" (quite_pretty_json (Github_j.string_of_release rel_list))
       )
    )
    (*
    (fun cookie_name () ->
       Lwt_main.run (
         Github_wrapper.login ~cookie_name
         >>= fun code ->
           Lwt_io.printf "%s\n" (quite_pretty_json (Github_j.string_of_auth code))
       )
    )
    *)

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
