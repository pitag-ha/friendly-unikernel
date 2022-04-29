open Lwt.Syntax

module Client
    (Client : Cohttp_lwt.S.Client)
    (Time : Mirage_time.S)
    (Random : Mirage_random.S) =
struct
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

  let msgs =
    [
      "<some friendly message> :heart:";
      "keep it going. it's sunny outside :slightly_smiling_face: (and if it \
       isn't, it will be soon :stuck_out_tongue: )";
      "just some more hours and then it's time for the pub :beers:";
      "today is climbing:woman_climbing: day or diving day (or whatever \
       activity you like day)!! (or, if it isn't today, it will be soon \
       :upside_down_face:";
      "time to have some chocolate :chocolate_bar: :stuck_out_tongue:";
      ":slightly_smiling_face:";
      ":upside_down_face:";
      "let's play a board game! :game_die:";
      ":sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy::sheepy:";
      ":mario_luigi_dance::congaparrot::mario_luigi_dance:";
      ":flailing-octopus::flailing-octopus::flailing-octopus::slightly_smiling_face::flailing-octopus::flailing-octopus::flailing-octopus:";
    ]

  let random_item list =
    let abs n = if n <= 0 then -n else n in
    let random_num =
      (Cstruct.HE.get_uint32 (Random.generate 4) 0 |> Int32.to_int |> abs)
      mod List.length list
    in
    List.nth list random_num

  let start ctx _time _generator =
    let uri = "https://slack.com/api/chat.postMessage" in
    let token = Key_gen.token () in
    let make_body msg =
      let channel = Key_gen.channel () in
      `Assoc [ ("channel", `String channel); ("text", `String msg) ]
    in
    let send_msg body =
      let+ res = make_json_request ~uri ~ctx ~body token in
      match res with
      | Ok _ -> ()
      | Error body ->
          print_endline "not quite yet: ";
          Format.printf "%s\n%!" body
    in
    let rec loop () =
      let* () = random_item msgs |> make_body |> send_msg in
      let* () = Time.sleep_ns (Duration.of_sec 5) in
      loop ()
    in
    loop ()
end
