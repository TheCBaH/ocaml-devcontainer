COMPCERT_DIR := modules/CompCert
COMPCERT_JOBS := $(shell nproc)
COMPCERT_EXTRACTION_ARCHIVE := compcert-extraction.tar.gz
COMPCERT_LIB_DIR := compcert-lib

default: compcert

# PLATFORM (linux/amd64, linux/i386, linux/arm/v7, ...) is the devcontainer
# action's generic Docker-platform env var, forwarded into the container via
# `devcontainer exec --remote-env`; when set it's preferred over `uname -m`,
# which isn't reliable here: on a 32-bit container running on a 64-bit host
# (e.g. linux/i386 on an amd64 host, linux/arm/v7 on an arm64 host) it
# reports the *host's* 64-bit machine type, not the container's, since
# nothing switches the process's kernel personality just because the
# image/binaries are 32-bit. This has to stay a shell expression run from
# the recipe (as opposed to a $(shell ...)-computed make variable): the case
# statement's bare `pattern)` labels contain unbalanced parentheses, which
# confuses make's own paren matching when used inside $(shell ...).
compcert-configure:
	cd $(COMPCERT_DIR) && opam exec -- ./configure $$(case "$$PLATFORM" in \
	  linux/aarch64|linux/arm64) echo aarch64-linux ;; \
	  linux/amd64|linux/x86_64) echo x86_64-linux ;; \
	  linux/i386|linux/386) echo x86_32-linux ;; \
	  linux/arm/v7*|linux/arm/v6*|linux/arm) echo arm-linux ;; \
	  *) m=$$(uname -m); case "$$m" in \
	       aarch64|arm64) echo aarch64-linux ;; \
	       x86_64|amd64) echo x86_64-linux ;; \
	       i686|i386) echo x86_32-linux ;; \
	       armv7l|armv6l|arm) echo arm-linux ;; \
	       *) echo x86_64-linux ;; \
	     esac ;; \
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
# `depend` has to run before `extraction`: CompCert's source lists (VLIB,
# COMMON, ...) name files without their subdirectory, and it's only the
# generated .depend file that tells make the .vo targets live under lib/,
# common/, etc. Without it, coqc gets invoked on bare filenames and fails to
# find them. CompCert's own `all`/`light` targets get this for free (they
# run `depend` before `proof`/`extraction`); calling `extraction` directly
# skips that, so it's done explicitly here.
compcert-extraction-archive: compcert-configure
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -j$(COMPCERT_JOBS) depend
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
