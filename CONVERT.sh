#!/bin/sh -ex

if test -f "$1"; then
	set -- "${1%.*.*}" "$1" "${1##*.}"

	case "$3" in
		br)  CMD='brotli' ;;
		bz2) CMD='bzip2' ;;
		gz)  CMD='pigz' ;;
		lz)  CMD='lzip' ;;
		lz4) CMD='lz4' ;;
		tgz) CMD='pigz' && set "${2%.*}" "$2" ;;
		xz)  CMD='xz' ;;
		zst) CMD='zstd' ;;
		*)   >&2 echo "UNRECOGNIZED TYPE ${3}" && exit 1 ;;
	esac

	if ! >'/dev/null' command -v "$CMD"; then
		>&2 echo "COMMAND ${CMD} NOT FOUND"
		exit 1
	fi

	<"$2" "$CMD" -d | pax -r
	rm "$2"
elif ! test -d "$1"; then
	>&2 echo "ARGUMENT ${1} IS NEITHER A FILE NOR A DIRECTORY"
	exit 1
fi

set -- "$1" "${1}.tar.gz"

pax -w -x ustar "$1" | >"$2" pigz -c -11
rm -Rf "$1"

test -f 'SHA256.txt' || touch 'SHA256.txt'
<'SHA256.txt' >'SHA256.txt.new' sed "/${2}/d"
mv SHA256.txt.new SHA256.txt

set -- "$2" $(<"$2" sha256sum)
>>'SHA256.txt' echo "${2}  ${1}"
