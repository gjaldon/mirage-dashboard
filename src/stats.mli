module Branches : (module type of Branches)
module Events : (module type of Events)
module Releases : (module type of Releases)
module Repo_info : (module type of Repo_info)

val test :
  string ->
  string
