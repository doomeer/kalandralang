(* USES clap *)
(* USES lwt *)
(* USES tls *)
(* USES cohttp-lwt-unix *)
(* USES ezjsonm *)
(* USES kalandralang.lib *)

open Kalandralang_lib

let (let*) = Lwt.bind

let respond ?(status = `OK) ~content_type body =
  Cohttp_lwt_unix.Server.respond_string
    ~headers: (Cohttp.Header.of_list [ "Content-Type", content_type ])
    ~status
    ~body
    ()

let not_found () =
  respond ~status: `Not_found ~content_type:"text/plain" "not found"

let serve _connection (request: Cohttp.Request.t) (body: Cohttp_lwt.Body.t) =
  try
    match request.meth with
      | `POST ->
          let uri = Uri.of_string request.resource in
          let path = Uri.path uri in
          if path = "/run" then
            let* body = Cohttp_lwt.Body.to_string body in
            let recipe = Parse.from_string body in
            let compiled_recipe = Linear.compile recipe in
            (* TODO: Option.iter Random.init seed;, and show_seed option?
               Or move that to Run.recipe? *)
            let display_options: Run.display_options =
              let no_item = false in
              let no_cost = false in
              let no_total = false in
              let no_echo = false in
              let summary = false in
              let short = false in
              {
                verbose = false;
                show_seed = false;
                no_item = no_item || summary || short;
                no_cost = no_cost || summary || short;
                no_total = no_total || summary;
                no_echo = no_echo || summary || short;
                no_histogram = false;
                show_time = false;
                summary;
              }
            in
            let batch_options: Run.batch_options =
              {
                count = 1;
                timeout = None;
                loop = false;
              }
            in
            let output_buffer = Buffer.create 1024 in
            let echo string =
              Buffer.add_string output_buffer string;
              Buffer.add_char output_buffer '\n'
            in
            match
              Run.recipe echo compiled_recipe ~batch_options ~display_options
                ~return_items: 10
            with
              | Ok results ->
                  respond ~content_type: "application/json"
                    (Ezjsonm.value_to_string
                       (Run.json_of_results
                          (`String (Buffer.contents output_buffer)) results))
              | Error message ->
                  respond ~status: `Bad_request ~content_type: "text/plain"
                    message
          else
            not_found ()
      | _ ->
          not_found ()
  with
    | Parse.Parse_error _ as exn ->
        respond ~status: `Bad_request ~content_type: "text/plain"
          (Printexc.to_string exn)
    | exn ->
        (* TODO: Log module? *)
        prerr_endline (Printexc.to_string exn);
        respond ~status: `Internal_server_error ~content_type: "text/plain"
          "internal server error: uncaught exception (see details in server logs)"

let () =
  let port =
    Clap.default_int
      ~long: "port"
      ~short: 'p'
      ~description: "Port to listen to."
      8080
  in
  let data_dir =
    Clap.optional_string
      ~long: "data-dir"
      ~placeholder: "PATH"
      ~description: "Path to data directory. \
                     On Linux, this defaults to: `~/.kalandralang/data/`. \
                     On other Platforms, this currently defaults to `./data/`."
      ()
  in
  Clap.close ();
  Data.load print_endline data_dir;
  Lwt_main.run @@
  Cohttp_lwt_unix.Server.create ~mode: (`TCP (`Port port))
    (Cohttp_lwt_unix.Server.make ~callback: serve ())
