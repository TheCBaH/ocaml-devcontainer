all: lib copy

CFLAGS=-W -Wall -fpic -FPIC -I pjrt

lib: libpjrt.a
	touch dllpjrt.so

copy:
	cp -p pjrt/pjrt_c_api.h pjrt_c_api.h.tmp
	sed -ie 's/ callback;/ callback_;/' pjrt_c_api.h.tmp
	mv pjrt_c_api.h.tmp pjrt_c_api.h

libpjrt.a: pjrt.c pjrt.h
	${CC} ${CFLAGS} -c pjrt.c -o pjrt.o
	ar rcs $@ pjrt.o

clean.lib:
	rm -f pjrt.o libpjrt.a dllpjrt.so

VERSION=0.0.1
SHA256=dbde0f4ed900009cd66d224edf3945d80c19a79eeaa7f19ecc2f753b42eed687
FILE=pjrt-cpu.tar.xz

download:
	wget -O ${FILE} https://github.com/TheCBaH/devcontainer.xla/releases/download/v${VERSION}/${FILE}
	set -eux;test "${SHA256}" = "$$(sha256sum ${FILE}|cut -f1 -d ' ')"
	set -eux;mkdir -p pjrt;cd pjrt;tar -Jxvf ../${FILE}
	rm ${FILE}

.PHONY: download
