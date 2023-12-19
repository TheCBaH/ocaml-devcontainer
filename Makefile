
default:
	opam exec dune build

format:
	opam exec dune fmt

run:
	opam exec dune exec ./main.exe

top:
	opam exec dune exec ./example_top.exe

utop:
	opam exec dune utop

clean.ffi:
	rm -rf obj* cross

clean: clean.ffi
	opam exec dune $@

ffi.build:
	${MAKE} -f Makefile.ffi test CROSS_COMPILER=$(if ${TARGET},${TARGET}-) ARCH=${ARCH} -j$$(getconf _NPROCESSORS_ONLN)

#VALGRIND_GEN_SUPP=--gen-suppressions=all --log-file=ocamlruntime.log
VALGRIND=$(if ${WITH_VALGRIND}, valgrind --suppressions=ocamlruntime.supp $(or ${VALGRIND_GEN_SUPP},--quiet --error-exitcode=127) --show-reachable=yes --leak-check=full)
ffi.run:
	$(if ${TARGET},,${VALGRIND}) ${TARGET} obj.${ARCH}/test.bin

OBJ=obj
ffi.common:
	rm -f ${OBJ}/hello.bc ${OBJ}/hello_bc.c
	mkdir -p ${OBJ}
	opam exec -- ocamlc -compat-32 -output-obj -o ${OBJ}/hello_bc.c -I src src/hello.ml src/test.ml src/ffi_test.ml main.ml

ffi.prepare:
	rm -rf cross/${ARCH} obj.${ARCH}
	./configure-target.sh .modules/ocaml '${TARGET}' cross/${ARCH}

ffi: ffi.common ffi.prepare ffi.build

%.arm:
	${MAKE} $(basename $@) TARGET=arm-linux-musleabi ARCH=arm

%.aarch64:
	${MAKE} $(basename $@) TARGET=aarch64-linux-musl ARCH=aarch64

%.i386:
	${MAKE} $(basename $@) TARGET=i386-linux-musl ARCH=i386

%.x86_64:
	${MAKE} $(basename $@) TARGET=x86_64-linux-musl ARCH=x86_64

%.native:
	${MAKE} $(basename $@) TARGET= ARCH=native

.PHONY: default clean format run top utop
