open Core.Std
open Github

let spec =
  let open Command.Spec in
  empty

let command =
  Command.basic
    ~summary: "A dashboard displaying useful data from the Mirage OS project and its related repositories."
    ~readme: (fun () -> "More detailed info")
    spec
    (fun () ->
       eprintf "coming soon...\n"
    )

let () =
  Command.run ~version:"0.1" ~build_info:"RWO" command
