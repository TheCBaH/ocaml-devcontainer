COMPCERT_DIR := modules/CompCert
COMPCERT_JOBS := $(shell nproc)
COMPCERT_EXTRACTION_ARCHIVE := compcert-extraction.tar.gz
COMPCERT_LIB_DIR := compcert-lib

default: compcert

compcert-configure:
	cd $(COMPCERT_DIR) && opam exec -- ./configure $$(m=$$(uname -m); case "$$m" in \
	  aarch64|arm64) echo aarch64-linux ;; \
	  x86_64|amd64) echo x86_64-linux ;; \
	  i686|i386) echo x86_32-linux ;; \
	  armv7l|armv6l|arm) echo arm-linux ;; \
	  *) echo x86_64-linux ;; \
	esac)

compcert-build:
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -j$(COMPCERT_JOBS) all

compcert-check-proof:
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) check-proof

compcert-test:
	cd $(COMPCERT_DIR)/test && opam exec -- $(MAKE) all
	cd $(COMPCERT_DIR)/test && opam exec -- $(MAKE) test

compcert: compcert-configure compcert-build

# Split build: run the Rocq-dependent proof + extraction once, archive the
# resulting sources, then let compcert-build-from-archive compile/link
# ccomp from that archive alone, without touching Rocq again (the CI
# workflow proves this by uninstalling rocq-prover before this runs).
# Makefile.config is included because CompCert's own ./configure refuses
# to run without Rocq present, even though its content (compiler paths,
# target arch, ...) has nothing to do with Rocq.
compcert-extraction-archive: compcert-configure
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -j$(COMPCERT_JOBS) extraction
	cd $(COMPCERT_DIR) && tar -czf ../../$(COMPCERT_EXTRACTION_ARCHIVE) \
	  Makefile.config extraction/*.ml extraction/*.mli

compcert-extraction-unarchive:
	tar -xzf $(COMPCERT_EXTRACTION_ARCHIVE) -C $(COMPCERT_DIR)

# Everything ccomp's OCaml side needs to compile, besides the extraction
# archive itself: the runtime config (compcert.ini/driver/Version.ml, both
# cheap shell substitutions - no Rocq) and the Menhir/ocamllex-generated
# parser files, pulled in as a side effect of computing .depend.extr.
compcert-prepare-sources: compcert-extraction-unarchive
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) compcert.ini driver/Version.ml
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -f Makefile.extr depend

compcert-build-from-archive: compcert-prepare-sources
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -f Makefile.extr ccomp

# Alternative to compcert-build-from-archive: instead of compiling/linking
# ccomp with CompCert's own hand-rolled ocamlc/ocamlopt+modorder Makefile,
# copy the same hand-written + generated sources out into compcert-lib/ (a
# standalone dune project, see compcert-lib/src/dune) and let dune resolve
# module dependencies and link a library + our own bin/main.ml, so CompCert
# can be depended on like an ordinary OCaml library. driver/Driver.ml is
# excluded from the library and copied to bin/main.ml instead, since it's
# ccomp's CLI entry point, not library code (see it for the ~3-call
# sequence - Frontend.parse_c_file / Compiler.transf_c_program / print -
# a from-scratch main.ml would drive the library the same way).
compcert-lib-sync: compcert-prepare-sources
	rm -f $(COMPCERT_LIB_DIR)/src/*.ml $(COMPCERT_LIB_DIR)/src/*.mli
	mkdir -p $(COMPCERT_LIB_DIR)/src $(COMPCERT_LIB_DIR)/bin
	arch=$$(grep '^ARCH=' $(COMPCERT_DIR)/Makefile.config | cut -d= -f2); \
	for d in extraction lib common $$arch backend cfrontend cparser export debug driver; do \
	  find $(COMPCERT_DIR)/$$d -maxdepth 1 \( -name '*.ml' -o -name '*.mli' \) \
	    ! -name 'Driver.ml' -exec cp {} $(COMPCERT_LIB_DIR)/src/ \; ; \
	done
	cp $(COMPCERT_DIR)/driver/Driver.ml $(COMPCERT_LIB_DIR)/bin/main.ml

compcert-lib-build: compcert-lib-sync
	cd $(COMPCERT_LIB_DIR) && opam exec -- dune build

# ccomp looks for compcert.ini next to its own executable (or via
# COMPCERT_CONFIG/-conf), which compcert-lib/_build isn't, so point it at
# the one compcert-prepare-sources generated in $(COMPCERT_DIR) instead of
# copying it into the dune tree.
compcert-lib-run: compcert-lib-build
	cd $(COMPCERT_LIB_DIR) && COMPCERT_CONFIG=$(CURDIR)/$(COMPCERT_DIR)/compcert.ini \
	  opam exec -- dune exec bin/main.exe -- $(ARGS)

.PHONY: default \
  compcert compcert-configure compcert-build compcert-check-proof compcert-test \
  compcert-extraction-archive compcert-extraction-unarchive compcert-prepare-sources \
  compcert-build-from-archive compcert-lib-sync compcert-lib-build compcert-lib-run
