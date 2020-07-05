open Core

module Process = Shexp_process
module P = Process

let default_script_path () =
  Filename.concat (FileUtil.pwd ()) "Satyristes"

let opam_with_build_module_command ~prefix_optionality f =
  let open Command.Let_syntax in
  let outf = Format.std_formatter in
  Command.basic
    ~summary:"Install module into OPAM registory (experimental)"
    [%map_open
      let prefix = flag "prefix" (prefix_optionality string) ~doc:"PREFIX Install destination"
      and script = flag "script" (optional string) ~doc:"SCRIPT Install script"
      and name = flag "name" (optional string) ~doc:"MODULE_NAME Module name"
      and verbose = flag "verbose" no_arg ~doc:"Make verbose"
      in
        let buildscript_path = Option.value ~default:(default_script_path ()) script in
        let env = Setup.read_environment () in
        Satyrographos_command.Opam.with_build_script f ~outf ~prefix ~buildscript_path ~name ~verbose ~env
    ]

let opam_build_command =
  opam_with_build_module_command ~prefix_optionality:Command.Param.optional Satyrographos_command.Opam.build_opam

let opam_install_command =
  opam_with_build_module_command ~prefix_optionality:Command.Param.required Satyrographos_command.Opam.install_opam

let opam_uninstall_command =
  let open Command.Let_syntax in
  let outf = Format.std_formatter in
  Command.basic
    ~summary:"DEPRECATED"
    [%map_open
      let _ = flag "prefix" (required string) ~doc:"PREFIX Install destination"
      and _ = flag "script" (optional string) ~doc:"SCRIPT Install script"
      and _ = flag "name" (optional string) ~doc:"MODULE_NAME Module name"
      and _ = flag "verbose" no_arg ~doc:"Make verbose"
      in
        fun () ->
          Format.fprintf outf "Warning: opam uninstall subcommand has been deprecated.  It does nothing now.\n"
    ]

let opam_buildfile_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Inspect build file (experimental)"
    [%map_open
      let f = anon ("BUILD_FILE" %: string) (* ToDo: Remove this *)
      and process = flag "process" no_arg ~doc:"Process the script"
      in
      fun () ->
        Compatibility.optin ();
        Satyrographos_command.Opam.buildfile ~outf:Format.std_formatter ~process f ()
    ]

let opam_export_command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Export build file (experimental)"
    [%map_open
      let f = anon ("BUILD_FILE" %: string) (* ToDo: Remove this *)
      in
      fun () ->
        Compatibility.optin ();
        Satyrographos_command.Opam.export f ()
    ]

let opam_command =
  Command.group ~summary:"OPAM related functionalities (experimental)"
    [ "build", opam_build_command;
      "install", opam_install_command;
      "uninstall", opam_uninstall_command;
      "buildfile", opam_buildfile_command;
      "export", opam_export_command;
    ]
