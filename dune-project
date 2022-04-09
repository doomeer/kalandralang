(lang dune 2.8)

(name kalandralang)

(generate_opam_files true)

(source (github doomeer/kalandralang))

(license MIT)

(authors DooMeeR)

(maintainers DooMeeR)

(package
 (name kalandralang)
 (synopsis "A language to express crafting recipes for Path of Exile")
 (description
  "This package provides an executable to read and execute crafting recipes for Path of Exile, to measure expected cost and/or profit.")
 (depends
  clap
  cohttp-lwt-unix
  ezjsonm
  lwt
  re
  uri))
