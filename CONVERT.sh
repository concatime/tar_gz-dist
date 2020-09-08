#!/bin/sh -xe

if test -f "$1"; then
	set "${1%.*.*}" "$1" "${1##*.}"

	case "$3" in
		br)  PROG='brotli' ;;
		bz2) PROG='bzip2' ;;
		gz)  PROG='pigz' ;;
		lz)  PROG='lzip' ;;
		lz4) PROG='lz4' ;;
		tgz) PROG='pigz' && set "${2%.*}" "$2" ;;
		xz)  PROG='xz' ;;
		zst) PROG='zstd' ;;
		*)   >&2 echo "UNRECOGNIZED TYPE ${3}" && exit 1 ;;
	esac

	if ! >'/dev/null' command -v "$PROG"; then
		>&2 echo "COMMAND ${PROG} NOT FOUND"
		exit 1
	fi

	<"$2" "$PROG" -d | pax -r
	rm "$2"
elif ! test -d "$1"; then
	>&2 echo "ARGUMENT ${1} IS NEITHER A FILE NOR A DIRECTORY"
	exit 1
fi

set "$1" "${1}.tar.gz"

pax -w "$1" | >"$2" pigz -c -11
rm -R "$1"

test -f 'SHA256.txt' || touch 'SHA256.txt'
<'SHA256.txt' >'SHA256.txt.new' sed "/${2}/d"
mv SHA256.txt.new SHA256.txt

sha256sum "$2" >> 'SHA256.txt'
