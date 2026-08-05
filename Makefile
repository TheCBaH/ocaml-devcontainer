COMPCERT_DIR := modules/CompCert
COMPCERT_ARCH := $(shell m=$$(uname -m); \
  if [ "$$m" = aarch64 ] || [ "$$m" = arm64 ]; then echo aarch64-linux; \
  elif [ "$$m" = x86_64 ] || [ "$$m" = amd64 ]; then echo x86_64-linux; \
  elif [ "$$m" = i686 ] || [ "$$m" = i386 ]; then echo x86_32-linux; \
  elif [ "$$m" = armv7l ] || [ "$$m" = armv6l ] || [ "$$m" = arm ]; then echo arm-linux; \
  else echo x86_64-linux; \
  fi)
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
