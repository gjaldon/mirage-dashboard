open Core.Std
open Github

let spec =
  let open Command.Spec in
  empty
    +> flag "-c" (required string) ~doc:"cookie github auth cookie, from git-jar"

let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun cookie () ->
       print_endline cookie
    )

let () =
  Command.run ~version:"0.1" ~build_info:"RWO" command
