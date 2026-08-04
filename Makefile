
default:
	opam exec -- dune build

hello: run

static:
	opam exec -- dune build --profile static

format:
	opam exec -- dune fmt

format-check:
	opam exec -- dune build @fmt

run:
	opam exec -- dune exec -- ./main.exe

top:
	opam exec -- dune exec -- ./example_top.exe

utop:
	opam exec -- dune utop

clean:
	opam exec -- dune $@

.PHONY: default clean format format-check run top utop
