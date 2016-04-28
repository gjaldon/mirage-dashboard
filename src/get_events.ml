open Lwt

(*
   * example data
   * https://api.github.com/repos/mirage/mirage/events
   *
   *)

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
      ("type", `String (Github_wrapper.strip_quotes (Yojson.Safe.to_string event_type)));
      ("user", `String (Github_wrapper.strip_quotes (Yojson.Safe.to_string user_name)));
      ("date", `String (Github_wrapper.strip_quotes (Yojson.Safe.to_string event_date)))
    ]
    
  )

let get_events ~cookie_name ~user ~repo =
  Github_wrapper.get_token ~cookie_name
  >>= fun token ->
  return (Github.Event.for_repo ~token ~user ~repo ())
  >>= fun stream ->
  Github_wrapper.stream_to_list stream
  >>= fun events_list ->
  return (
    `List (
      List.map 
        (
          fun event ->
            extract_type_and_user_name (Github_j.string_of_event event)
        )
        events_list
    )
  )
