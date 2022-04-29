open Mirage

let uri =
  let doc = Key.Arg.info ~doc:"slack bot token" [ "token" ] in
  Key.(create "token" Arg.(required string doc))

let client =
  let packages = [ package "cohttp-mirage"; package "duration"; package "yojson" ] in
  main ~keys:[ key uri ] ~packages "Unikernel.Client" @@ http_client @-> job

let () =
  let stack = generic_stackv4v6 default_network in
  let res_dns = resolver_dns stack in
  let conduit = conduit_direct ~tls:true stack in
  let job = [ client $ cohttp_client res_dns conduit ] in
  register "http-fetch" job
