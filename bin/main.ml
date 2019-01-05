open Satyrographos
open Core

let scheme_version = 1

let prefix = match SatysfiDirs.home_dir () with
  | Some(d) -> d
  | None -> failwith "Cannot find home directory"

let user_dir = Filename.concat prefix ".satysfi"
let root_dir = Filename.concat prefix ".satyrographos"
let repository_dir = Filename.concat root_dir "repo"
let package_dir = Filename.concat root_dir "packages"
let metadata_file = Filename.concat root_dir "metadata"

let current_scheme_version = Version.get_version root_dir

let compatibility_optin () =
  match Sys.getenv "SATYROGRAPHOS_EXPERIMENTAL" with
  | Some "1" ->
    Printf.printf "Compatibility warning: You have opted in to use experimental features.\n"
  | _ ->
    Printf.printf "Compatibility warning: This is an experimental feature.\n";
    Printf.printf "You have to opt in by setting env variable SATYROGRAPHOS_EXPERIMENTAL=1 to test this feature.\n";
    exit 1

let opam_share_dir =
  Unix.open_process_in "opam var share"
  |> In_channel.input_all
  |> String.strip

(* TODO Move this to a new module *)
let initialize () =
  match current_scheme_version with
  | None ->
    Repository.initialize repository_dir metadata_file;
    Registory.initialize package_dir metadata_file;
    Version.mark_version root_dir scheme_version
  | Some 0 -> Printf.sprintf "Semantics of `pin add` has been changed.\nPlease remove %s to continue." root_dir |> failwith
  | Some 1 -> ()
  | Some v -> Printf.sprintf "Unknown scheme version %d" v |> failwith

let () =
  initialize ()

let repo = Repository.read repository_dir metadata_file
let reg = Registory.read package_dir repo metadata_file
let reg_opam =
  Printf.printf "opam dir: %s\n" opam_share_dir;
  {SatysfiRegistory.package_dir=Filename.concat opam_share_dir "satysfi"}

let status () =
  printf "scheme version: ";
  [%derive.show: int option] current_scheme_version |> print_endline;
  [%derive.show: string list] (Repository.list repo) |> print_endline;
  [%derive.show: string list] (Registory.list reg) |> print_endline;
  [%derive.show: string list] (SatysfiDirs.runtime_dirs ()) |> print_endline;
  [%derive.show: string option] (SatysfiDirs.user_dir ()) |> print_endline

let pin_list () =
  compatibility_optin ();
  [%derive.show: string list] (Repository.list repo) |> print_endline
let pin_list_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"List installed packages (experimental)"
    [%map_open
      let _ = args (* ToDo: Remove this *)
      in
      fun () ->
        pin_list ()
    ]

let pin_dir p () =
  compatibility_optin ();
  Repository.directory repo p |> print_endline
let pin_dir_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Get directory where package PACKAGE is stored (experimental)"
    [%map_open
      let p = anon ("PACKAGE" %: string)
      in
      fun () ->
        pin_dir p ()
    ]

let pin_add p url () =
  compatibility_optin ();
  Printf.printf "Compatibility warning: Although currently Satyrographos simply copies the given directory,\n";
  Printf.printf "it will have a build script to control package installation, which is a breaking change.";
  Uri.of_string url
  |> Repository.add repo p
  |> ignore;
  Printf.printf "Added %s (%s)\n" p url;
  Registory.update_all reg
  |> [%derive.show: string list option]
  |> Printf.printf "Built packages: %s\n"
let pin_add_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Add package with name PACKAGE copying from URL (experimental)"
    [%map_open
      let p = anon ("PACKAGE" %: string)
      and url = anon ("URL" %: string) (* TODO define Url.t Arg_type.t *)
      in
      fun () ->
        pin_add p url ()
    ]

let pin_remove p () =
  compatibility_optin ();
  (* TODO remove the package *)
  Repository.remove repo p;
  Printf.printf "Removed %s\n" p
let pin_remove_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Remove package (experimental)"
    [%map_open
      let p = anon ("PACKAGE" %: string) (* ToDo: Remove this *)
      in
      fun () ->
        pin_remove p ()
    ]

let pin_command =
  Command.group ~summary:"Manipulate packages (experimental)"
    [ "list", pin_list_command; (* ToDo: use this default*)
      "dir", pin_dir_command;
      "add", pin_add_command;
      "remove", pin_remove_command;
    ]


let package_show_command_g p_show =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Show package information (experimental)"
    [%map_open
      let p = anon ("PACKAGE" %: string)
      in
      fun () ->
        p_show p ()
    ]
let package_list_command_g p_list =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Show list of packages installed (experimental)"
    [%map_open
      let _ = args (* ToDo: Remove this *)
      in
      fun () ->
        p_list ()
    ]

let package_list () =
  compatibility_optin ();
  [%derive.show: string list] (Registory.list reg) |> print_endline
let package_list_command =
  package_list_command_g package_list

let package_show p () =
  compatibility_optin ();
  Registory.directory reg p
    |> Package.read_dir
    |> [%derive.show: Package.t]
    |> print_endline
let package_show_command =
  package_show_command_g package_show

let package_command =
  Command.group ~summary:"Install packages (experimental)"
    [ "list", package_list_command; (* ToDo: use this default*)
      "show", package_show_command;
    ]


let package_opam_list () =
  compatibility_optin ();
  [%derive.show: string list] (SatysfiRegistory.list reg_opam) |> print_endline
let package_opam_list_command =
  package_list_command_g package_opam_list

let package_opam_show p () =
  compatibility_optin ();
  SatysfiRegistory.directory reg_opam p
    |> Package.read_dir
    |> [%derive.show: Package.t]
    |> print_endline
let package_opam_show_command =
  package_show_command_g package_opam_show

let package_opam_command =
  Command.group ~summary:"Inspect packages installed with OPAM (experimental)"
    [ "list", package_opam_list_command; (* ToDo: use this default*)
      "show", package_opam_show_command;
    ]


let install d () =
  let user_packages = Registory.list reg
    |> List.map ~f:(Registory.directory reg)
  in
  let dist_packages = SatysfiRegistory.list reg_opam
    |> List.map ~f:(SatysfiRegistory.directory reg_opam)
  in
  let packages = List.append user_packages dist_packages
    |> List.map ~f:Package.read_dir
  in
  let merged = packages
    |> List.fold_left ~f:Package.union ~init:Package.empty
  in
  (* TODO build all *)
  Printf.printf "Updating packages\n";
  begin match Repository.update_all repo with
  | Some updated_packages -> begin
    Printf.printf "Updated packages\n";
    [%derive.show: string list] updated_packages |> print_endline
  end
  | None ->
    Printf.printf "No packages updated\n"
  end;
  Printf.printf "Building updated packages\n";
  begin match Registory.update_all reg with
  | Some updated_packages -> begin
    Printf.printf "built packages\n";
    [%derive.show: string list] updated_packages |> print_endline
  end
  | None ->
    Printf.printf "No packages built\n"
  end;
  match FileUtil.test FileUtil.Is_dir d, Package.is_managed_dir d with
  | true, false ->
    Printf.printf "Directory %s is not managed by Satyrographos.\n" d;
    Printf.printf "Please remove %s first.\n" d
  | _, _ ->
    Printf.printf "Remove destination %s \n" d;
    FileUtil.(rm ~force:Force ~recurse:true [d]);
    Package.mark_managed_dir d;
    Printf.printf "Loaded packages\n";
    [%derive.show: Package.t list] packages |> print_endline;
    Printf.printf "Installing to %s\n" d;
    [%derive.show: Package.t] merged |> print_endline;
    Package.write_dir d merged;
    Printf.printf "Installation completed!\n";
    List.iter ~f:(Printf.printf "(WARNING) %s") (Package.validate merged)

let install_command =
  let open Command.Let_syntax in
  let default_target_dir =
    Sys.getenv "SATYSFI_RUNTIME"
    |> Option.value ~default:(Filename.concat user_dir "dist") in
  let readme () =
    sprintf "Install SATySFi Libraries to a directory environmental variable SATYSFI_RUNTIME has or %s. Currently it accepts an argument DIR, but this is experimental." default_target_dir
  in
  Command.basic
    ~summary:"Install SATySFi runtime"
    ~readme
    [%map_open
      let target_dir = anon (maybe_with_default default_target_dir ("DIR" %: file))
      in
      fun () ->
        install target_dir ()
    ]

let status_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Show status (experimental)"
    [%map_open
      let _ = args (* ToDo: Remove this *)
      in
      fun () ->
        status ()
    ]

let total_command =
  Command.group ~summary:"Simple SATySFi Package Manager"
    [
      "package", package_command;
      "package-opam", package_opam_command;
      "status", status_command;
      "pin", pin_command;
      "install", install_command;
    ]

let () =
  Command.run ~version:"0.0.1.1" ~build_info:"RWO" total_command
