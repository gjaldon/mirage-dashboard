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
  | "" -> Lwt.fail (Auth_token_not_found "must specify jar token id/cookie_name")
  | _ -> get_auth_token_from_jar cookie_name
