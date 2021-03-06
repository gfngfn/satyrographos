module StdList = List

open TestLib

open Shexp_process

let env ~dest_dir ~temp_dir : Satyrographos.Environment.t t =
  let open Shexp_process.Infix in
  let empty_dist = FilePath.concat temp_dir "empty_dist" in
  PrepareDist.empty empty_dist
  >> mkdir (FilePath.concat dest_dir "dest")
  >> return Satyrographos.Environment.{
    repo = None;
    opam_reg = None;
    dist_library_dir = Some empty_dist;
  }

let () =
  let system_font_prefix = None in
  let libraries = None in
  let verbose = true in
  let copy = false in
  let main env ~dest_dir ~temp_dir:_ =
    let dest_dir = FilePath.concat dest_dir "dest" in
    Satyrographos_command.Install.install dest_dir ~system_font_prefix ~libraries ~verbose ~copy ~env () in
  eval (test_install env main)
