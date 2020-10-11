Prepare SATySFi source
  $ cat >first.saty <<EOF
  > @import: second
  > @require: lib1
  > EOF
  $ mkdir root

Generate dependency graphs
  $ SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos debug depgraph --satysfi-root-dirs 'root' --follow-require first.saty
  Compatibility warning: You have opted in to use experimental features.
  Cannot read files for “@import: second”
  Candidate basenames:
    - second
  
  Cannot read files for “@require: lib1”
  Candidate basenames:
    - root/dist/packages/lib1
    - root/local/packages/lib1
  
  digraph G {
    "second" [shape=doubleoctagon, ];
    "lib1" [shape=ellipse, ];
    "first.saty" [shape=box, ];
    
    
    "first.saty" -> "second" [color="#004422", fontcolor="#004422",
                              label="@import: second", ];
    "first.saty" -> "lib1" [color="#004422", fontcolor="#004422",
                            label="@require: lib1", ];
    
    }
