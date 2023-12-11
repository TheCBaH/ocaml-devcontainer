#!/bin/sh
set -e
set -x

echo "Activating feature 'musl-cross'"
dest=${1:-/usr/local}

ARCHITECTURES=${ARCHITECTURES:-undefined}
echo "Selected architectures: $ARCHITECTURES"

base_url='https://github.com/TheCBaH/musl-cross-make.builder/releases/download'
ver='v0.0.2'
gcc='9.4.0'
host='static'

for arch in ${ARCHITECTURES}; do
# https://github.com/TheCBaH/musl-cross-make.builder/releases/download/v0.0.2/musl-cross-aarch64-linux-musl-gcc9.4.0-static.tar.xz
    arch_base="${arch%.*}"
    arch_flavor=''
    if [ "$arch_base" != "$arch" ]; then
        arch_flavor="${arch#*.}"
    fi
    fname="musl-cross-$arch_base-linux-musl$arch_flavor-gcc$gcc-$host.tar.xz"
    url="$base_url/$ver/$fname"
    fname="/tmp/$fname"
    curl --fail --location --show-error -o $fname $url
    xz -d $fname
    fname="${fname%.xz}"
    tar -xf $fname -C ${1:-/usr/local}
    rm -f $fname
done
