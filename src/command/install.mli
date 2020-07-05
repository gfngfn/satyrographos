open Satyrographos
open Types

val get_libraries :
  outf:Format.formatter ->
  maybe_reg:Registry.t option ->
  env:Environment.t ->
  libraries:string list option ->
  (string, Library.t, StringSet.Elt.comparator_witness) Base.Map.t

val install_libraries :
  string ->
  outf:Format.formatter ->
  library_map:(string, Library.t, 'a) Base.Map.t ->
  verbose:bool ->
  copy:bool ->
  unit -> unit

val install :
  string ->
  outf:Format.formatter ->
  system_font_prefix:string option ->
  ?autogen_libraries:string list ->
  libraries:string list option ->
  verbose:bool ->
  copy:bool ->
  env:Environment.t ->
  unit -> unit
