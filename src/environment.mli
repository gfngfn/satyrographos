(** Satyrographos depot. TODO Rename *)
type repo = {

  repo: Repository.t;
  (** Satyrographos repository, which is a store of sourcecodes. *)

  reg: Registry.t;
  (** Satyrographos registry, which is a store of built files. *)
}

(** A type represents runtime environment. *)
type t = {
  repo: repo option;
  (** Satyrographos depot. I.e., ~/.satyrograpos.
      TODO Rename with depot. *)

  opam_reg: OpamSatysfiRegistry.t option;
  (** OPAM Registry. I.e., ~/.satyrograpos *)

  dist_library_dir: string option;
  (** A directory with SATySFi dist for the current SATySFi compiler.
      Typically, this points a directory under OPAM reg or /usr/local/share/satysfi/dist. *)
}
