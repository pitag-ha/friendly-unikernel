open Lwt.Syntax
open Printf

let red fmt = sprintf ("\027[31m" ^^ fmt ^^ "\027[m")
let green fmt = sprintf ("\027[32m" ^^ fmt ^^ "\027[m")
let yellow fmt = sprintf ("\027[33m" ^^ fmt ^^ "\027[m")
let blue fmt = sprintf ("\027[36m" ^^ fmt ^^ "\027[m")
module Client (Client : Cohttp_lwt.S.Client) = struct
  let make_json_request ~uri ~ctx ?body token =
    let uri = Uri.of_string uri in
    let headers extra_headers =
      Cohttp.Header.of_list
        (("Authorization", "Bearer " ^ token) :: extra_headers)
    in
    let* rsp, body =
      match body with
      | Some body ->
          let serialized_body = Yojson.Basic.to_string body in
          let headers = headers [ ("Content-type", "application/json") ] in
          Client.post ~ctx ~headers ~body:(`String serialized_body) uri
      | None ->
          let headers = headers [] in
          Client.get ~ctx ~headers uri
    in
    let+ body = Cohttp_lwt.Body.to_string body in
    if Cohttp.Code.(code_of_status rsp.status |> is_success) then Ok body
    else Error body

  let start ctx =
    let uri = "https://slack.com/api/chat.postMessage" in
    let token = (Key_gen.token ()) in
    let body =
      let channel = "C03D2UMKGT1" in
      let msg = "Some friendly message :heart:" in
      `Assoc [ ("channel", `String channel); ("text", `String msg) ]
    in
    let+ res = make_json_request ~uri ~ctx ~body token in
    let body = match res with
      | Ok body -> print_endline "Success :): "; body
      | Error body -> print_endline "not quite yet: "; body
    in Format.printf "%s\n%!" body
end
