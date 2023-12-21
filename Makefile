
default:
	opam exec dune build

format:
	opam exec dune fmt

run:
	opam exec dune exec ./main.exe

df.run:
	opam exec dune exec ./$(basename $@)/$(basename $@).exe

OPAM_EXEC=$(if $(shell which opam),opam exec --)
df.native:
	cd df && ${OPAM_EXEC} ocamlopt.opt -o df.bin.exe unix.cmxa types.mli types.ml df.ml
	cd df && time ./df.bin.exe

df.byte:
	cd df && ${OPAM_EXEC} ocamlc -o df.bc.exe unix.cma types.mli types.ml df.ml
	cd df && time ./df.bc.exe

top:
	opam exec dune exec ./example_top.exe

utop:
	opam exec dune utop

clean:
	opam exec dune $@

.PHONY: default clean format run top utop
