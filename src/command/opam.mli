open Satyrographos

val build_opam :
  outf:Format.formatter ->
  verbose:bool ->
  prefix:'c ->
  build_module:BuildScript.m ->
  buildscript_path:string ->
  env:Environment.t ->
  unit

val install_opam :
  outf:Format.formatter ->
  verbose:bool ->
  prefix:string ->
  build_module:BuildScript.m ->
  buildscript_path:string ->
  env:Environment.t ->
  unit

val uninstall_opam :
  outf:'a ->
  verbose:'b ->
  prefix:string ->
  build_module:BuildScript.m ->
  buildscript_path:'c ->
  env:'d ->
  unit

val buildfile :
  outf:Format.formatter ->
  process:bool ->
  string -> unit -> unit

val export :
  string -> unit -> unit

val with_build_script :
  (outf:'a ->
   verbose:'b ->
   prefix:'c ->
   build_module:BuildScript.m ->
   buildscript_path:string ->
   env:'d ->
   'e) ->
  outf:'a ->
  prefix:'c ->
  buildscript_path:string ->
  name:string option ->
  verbose:'b ->
  env:'d ->
  unit -> 'e
