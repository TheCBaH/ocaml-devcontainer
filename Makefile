COMPCERT_DIR := modules/CompCert
COMPCERT_JOBS := $(shell nproc)
COMPCERT_EXTRACTION_ARCHIVE := compcert-extraction.tar.gz

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

compcert-build-from-archive: compcert-extraction-unarchive
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) compcert.ini driver/Version.ml
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -f Makefile.extr depend
	cd $(COMPCERT_DIR) && opam exec -- $(MAKE) -f Makefile.extr ccomp

.PHONY: default \
  compcert compcert-configure compcert-build compcert-check-proof compcert-test \
  compcert-extraction-archive compcert-extraction-unarchive compcert-build-from-archive
