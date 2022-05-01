open Misc

type paths =
  {
      data_path: string;
      cache: string;
      costs: string;
  }

let poe_data = [
  ( (Base_item.load),        "base_items.json" );
  ( (Mod.load),              "mods.json" );
  ( (Stat_translation.load), "stat_translations.json" );
  ( (Essence.load),          "essences.json" );
]

let get_paths data_dir =
  let data_path = 
    match data_dir with
      | Some data_dir -> data_dir
      | None -> 
          match Sys.os_type with
            | "Unix" ->
                let userid = Unix.getuid () in
                let home = (Unix.getpwuid userid).pw_dir in
                let kld_path = home // ".kalandralang" in
                let result = kld_path // "data/" in
                result
            | "Win32" ->
                (* Not implemented, use current folder for data *)
                "data/"
            | "Cygwin" ->
                (* Not implemented, use current folder for data *)
                "data/"
            | _ ->
                "data/"
  in
  let () = 
    Misc.mkdir_p data_path;
  in
  let cache = data_path // "kalandralang.cache" in
  let costs = data_path // "costs.json" in
  {
    data_path; 
    cache; 
    costs;
  }

let load_data data_dir = 
  let path = get_paths data_dir in
    let module_load mdl filepath = 
      let filename = Filename.basename filepath in
      echo "Loading %s..." filename;
      mdl filepath
    in
    let load_from_json () =
      (* Loads all files and modules specified in poe_data *)
      let module_load_json (mdl, file) =
        let filepath = path.data_path // file in
        if not (Sys.file_exists filepath) then
          fail "PoE-Data: %s does not exist.\nRun `kalandralang --update-data` to initilize data." file;
        module_load mdl filepath;
      in 
      List.iter module_load_json poe_data
    in
    let save_to_data () =
      (* Saving cache data to harddrive *)
      echo "Writing %s to speed up future loadings..." path.cache;
      Cache.export path.cache;
    in
    let load_from_data () = (
      (* Tries loading Cache, true = success, false = failed *)
      let ret = module_load (Cache.import) path.cache in
      match ret with
        | Failed_to_load ->
            echo "Failed to read cache from: %s" path.cache;
            false
        | Wrong_version ->
            echo "%s is from a different version and cannot be loaded." path.cache;
            false
        | Loaded ->
            true
    )
    in (
      if Sys.file_exists path.cache then (
        if not (load_from_data ()) then (
          load_from_json ();
          save_to_data ();
        );
      ) else (
        load_from_json ();
        save_to_data ();
      );
    )

let load data_dir = (
    load_data data_dir;
    let path = get_paths data_dir in
    if Sys.file_exists path.costs then (
      echo "Loading %s..." path.costs;
      Cost.load path.costs;
    ) else (
      echo "%s does not exist, will use default values." path.costs;
      echo "Use the 'write-default-costs' or 'update-costs' command to create it.";
    );
    echo "Ready.";
  )

let update_costs data_dir ~ninja_league ~tft_league =
  let path = get_paths data_dir in
  Ninja.write_costs ~ninja_league ~tft_league ~filename: path.costs

let write_default_costs data_dir =
  let path = get_paths data_dir in
  Cost.write_defaults path.costs 

let update_poe_data data_dir = 
  let update_poe_data_file filepath =
  let filename = Filename.basename filepath in
  let etag_file = filepath ^ ".etag" in
    let etag =
      if Sys.file_exists etag_file then (
        let ic = open_in etag_file in
        let etag = input_line ic in
        close_in ic;
        etag
      ) else
        ""
    in
    let request_etag =
      let headers = 
        if Sys.file_exists filepath then
          (* file already exists, attach etag to only get the file data if there is an update*)
          Http_request.header_create()
          |>Http_request.header_add "If-None-Match" etag
        else
          Http_request.header_create()
      in
      echo "Checking/Downloading %s" filename;
      Uri.of_string("https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/" ^ filename)
      |>Http_request.download ~headers filepath 
      |>Http_request.get_header "etag"
    in
    match request_etag with
      | Some request_etag -> 
        if request_etag <> etag then (
          echo " - %s got updated." filename;
          let oc = open_out etag_file in
          Printf.fprintf oc "%s" request_etag;
          close_out oc;
        ) else (
          echo " - %s is up to date." filename
        )
      | _ -> 
        (* Should never happen *)
        fail "Could not retrieve ETag from download.."
  in
  let path = get_paths data_dir in
  let update_poe_data_files (_, file) =
    let filepath = path.data_path // file in
    update_poe_data_file filepath;
  in 
  List.iter update_poe_data_files poe_data

let update_data data_dir = 
  let path = get_paths data_dir in
  update_poe_data data_dir;
  if Sys.file_exists path.cache then
    Sys.remove path.cache;
  load_data data_dir
  
