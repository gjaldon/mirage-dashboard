open Lwt
open Github_t

module G = Github
module M = Github.Monad

exception Auth_token_not_found of string

let get_auth_token_from_jar auth_id = 
  Github_cookie_jar.init ()
  >>= fun jar ->
    Github_cookie_jar.get jar auth_id
    >>= function
    | Some(x) -> return x
    | None -> Lwt.fail (Auth_token_not_found "given id not in cookie jar")

let login ~cookie_name =
  match cookie_name with
  | "" -> Lwt.fail (Auth_token_not_found "must specify jar token id/cookie_name")
  | _ -> get_auth_token_from_jar cookie_name

let get_token ~cookie_name =
  login ~cookie_name
  >>= fun code ->
    return (G.Token.of_auth code)

let get_release_for_repo ~token ~user ~repo =
  return (G.Release.for_repo ~token ~user ~repo ())

let get_release ~cookie_name ~user ~repo =
  get_token ~cookie_name
  >>= fun token ->
  get_release_for_repo ~token ~user ~repo

let release_to_list releases =
  G.(
    M.(
      run (
        Stream.to_list releases
      )
    )
  )

let release_strings release_list =
  List.map (fun rel -> Github_j.string_of_release rel) release_list