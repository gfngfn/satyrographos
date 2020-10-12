open Core

open Satyrographos_satysfi


let depgraph_command =
  let open Command.Let_syntax in
  let readme () =
    sprintf "Output dependency graph (EXPERIMENTAL)"
  in
  Command.basic
    ~summary:"Output dependency graph"
    ~readme
    [%map_open
      let runtime_dirs = flag "--satysfi-root-dirs" (optional string) ~aliases:["C"] ~doc:"DIRs Colon-separated list of SATySFi root directories"
      and _verbose = flag "--verbose" no_arg ~doc:"Make verbose"
      and follow_required = flag "--follow-required" no_arg ~aliases:["r"] ~doc:"Follow required package files"
      and satysfi_files = anon (non_empty_sequence_as_list ("FILE" %: string))
      in
      fun () ->
        Compatibility.optin ();
        let runtime_dirs = match runtime_dirs with
          | Some runtime_dirs ->
            String.split ~on:':' runtime_dirs
          | None ->
            let open SatysfiDirs in
            Option.to_list (user_dir ()) @ runtime_dirs ()
        in
        let outf = Format.err_formatter in
        (* TODO detect Satysfi version *)
        let satysfi_version = Version.Satysfi_0_0_5 in
        let package_root_dirs = SatysfiDirs.expand_package_root_dirs ~satysfi_version runtime_dirs in
        let g = DependencyGraph.dependency_graph ~outf ~package_root_dirs ~follow_required satysfi_files in
        DependencyGraph.Dot.fprint_graph Format.std_formatter g
    ]

let debug_command =
  Command.group ~summary:"SATySFi related utilities for debugging Satyrographos (experimental)"
    [ "depgraph", depgraph_command;
    ]
