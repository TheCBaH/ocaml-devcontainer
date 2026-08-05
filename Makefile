COMPCERT_DIR := modules/CompCert
COMPCERT_ARCH := $(shell m=$$(uname -m); \
  case "$$m" in \
    aarch64|arm64) echo aarch64-linux ;; \
    x86_64|amd64) echo x86_64-linux ;; \
    i686|i386) echo x86_32-linux ;; \
    armv7l|armv6l|arm) echo arm-linux ;; \
    *) echo x86_64-linux ;; \
  esac)
COMPCERT_JOBS := $(shell nproc)

default: compcert

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

.PHONY: default \
  compcert compcert-configure compcert-build compcert-check-proof compcert-test
