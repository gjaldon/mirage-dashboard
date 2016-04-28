open Lwt
open Core.Std

(*
   * example data
   * https://api.github.com/repos/mirage/mirage/events
   *
   *)

let clean_str json_str =
  Github_wrapper.strip_quotes (Yojson.Safe.to_string json_str)


let extract_type_and_user_name event_str =
  let event_data = Yojson.Safe.from_string event_str in
  let event_date = (
    Yojson.Safe.Util.member
      "created_at"
      event_data
  ) in
  let event_type = (
    Yojson.Safe.Util.member
      "type"
      event_data
  ) in
  let actor = (Yojson.Safe.Util.member "actor" event_data) in
  let user_name = (Yojson.Safe.Util.member "login" actor) in (
    `Assoc [
      ("type", `String (clean_str event_type));
      ("user", `String (clean_str user_name));
      ("date", `String (clean_str event_date))
    ]
  )

let extract_user event_str =
  let event_data = Yojson.Safe.from_string event_str in
  let actor = (Yojson.Safe.Util.member "actor" event_data) in
  let user_name = (Yojson.Safe.Util.member "login" actor) in (
    clean_str user_name
  )


let rec count_user user_list user_name =
  match user_list with
  | [] -> [(user_name, 1)]
  | (u_name, i) :: tl ->
    if u_name = user_name
    then
      (u_name, i + 1) :: tl
    else
      (u_name, i) :: count_user tl user_name

let count_users all_users =
  List.fold
    ~init: []
    ~f:(
      fun accum user ->
        count_user accum user
    )
    all_users

let user_counts_to_json user_list =
  `Assoc (
    List.map
      ~f:(
        fun user_tuple ->
          let (name, count) = user_tuple in
          (name, `Int count)
      )
      user_list
  )

let get_events_per_user ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  return (Github.Event.for_repo ~token ~user ~repo ())
  >>= fun stream ->
  Github_wrapper.stream_to_list stream
  >>= fun events_list ->
  return (
    List.map 
      ~f:(
        fun event ->
          extract_user (Github_j.string_of_event event)
      )
      events_list
    |> count_users
    |> user_counts_to_json
  )
