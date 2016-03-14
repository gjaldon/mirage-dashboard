open Core.Std
open Lwt

open Github_t
module G = Github
module M = Github.Monad

exception Auth_token_not_found of string

let get_auth_token_from_jar auth_id = 
  lwt jar = Github_cookie_jar.init () in
Github_cookie_jar.get jar auth_id >>= function
    | Some(x) -> return x
    | None -> Lwt.fail (Auth_token_not_found "given id not in cookie jar")

let login ~cookie_name =
  match cookie_name with
  | "" -> Lwt.fail (Auth_token_not_found "must specify username or jar token id")
  | _ -> get_auth_token_from_jar cookie_name


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
       Lwt_main.run (
         login ~cookie_name:cookie >>= fun code ->
         Lwt_io.printf "%s\n" (Github_j.string_of_auth code)
       )
    )

let () =
  Command.run ~version:"0.1" ~build_info:"https://github.com/rudenoise/mirage-dashboard" command
