Create a new document with doc-make@en template
  $ SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos new doc-make@en --license CC-BY-4.0 test-doc-en
  Compatibility warning: You have opted in to use experimental features.
  Name: test-doc-en
  License: CC-BY-4.0
  Created a new library/document.

Try to build when there is satysfi command
  $ if command satysfi --version >/dev/null 2>&1 && opam list -i --silent satysfi-dist && opam list -i --silent satysfi-fss ; then
  >   cd test-doc-en
  >   SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos build >build.log 2>&1
  >   [ -f main.pdf ] || cat build.log
  >   cd ..
  > fi

Create a new document with doc-make@ja template
  $ SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos new doc-make@ja --license CC-BY-4.0 test-doc-ja
  Compatibility warning: You have opted in to use experimental features.
  Name: test-doc-ja
  License: CC-BY-4.0
  Created a new library/document.

Try to build when there is satysfi command
  $ if command satysfi --version >/dev/null 2>&1 && opam list -i --silent satysfi-dist && opam list -i --silent satysfi-fss ; then
  >   cd test-doc-ja
  >   SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos build >build.log 2>&1
  >   [ -f main.pdf ] || cat build.log
  >   cd ..
  > fi

Ensure there are no warnings
  $ SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos lint -W '-lib/dep/exception-during-setup' --script test-doc-en/Satyristes --satysfi-version 0.0.5
  Compatibility warning: You have opted in to use experimental features.
  WARNING: Script lang 0.0.3 is under development.
  0 problem(s) found.
  $ SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos lint -W '-lib/dep/exception-during-setup' --script test-doc-ja/Satyristes --satysfi-version 0.0.5
  Compatibility warning: You have opted in to use experimental features.
  WARNING: Script lang 0.0.3 is under development.
  0 problem(s) found.