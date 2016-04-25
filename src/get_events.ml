open Lwt

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
            `String (Github_j.string_of_event event)
        )
        events_list
    )
  )
