
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

COMPCERT_DIR := modules/CompCert
COMPCERT_ARCH := $(shell m=$$(uname -m); if [ "$$m" = "aarch64" ] || [ "$$m" = "arm64" ]; then echo aarch64-linux; else echo x86_64-linux; fi)
COMPCERT_JOBS := $(shell nproc)

compcert-configure:
	cd $(COMPCERT_DIR) && opam exec -- ./configure $(COMPCERT_ARCH)

compcert-build:
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -j$(COMPCERT_JOBS) all

compcert-check-proof:
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) check-proof

compcert-test:
	cd $(COMPCERT_DIR)/test && opam exec -- $(MAKE) all
	cd $(COMPCERT_DIR)/test && opam exec -- $(MAKE) test

compcert: compcert-configure compcert-build

.PHONY: default clean format format-check run top utop \
  compcert compcert-configure compcert-build compcert-check-proof compcert-test
