#!/bin/sh
set -ex

if test -f "$1"; then
	set -- "${1%.*.*}" "$1" "${1##*.}"

	case "$3" in
		br)  CMD='brotli' ;;
		bz2) CMD='bzip2' ;;
		gz)  CMD='gzip' ;;
		lz)  CMD='lzip' ;;
		lz4) CMD='lz4' ;;
		tgz) CMD='gzip' && set "${2%.*}" "$2" ;;
		xz)  CMD='xz' ;;
		zst) CMD='zstd' ;;
		*)   echo "UNRECOGNIZED TYPE ${3}" >&2 && exit 1 ;;
	esac

	if ! command -v "$CMD" >'/dev/null'; then
		echo "COMMAND ${CMD} NOT FOUND" >&2
		exit 1
	fi

	"$CMD" -dc <"$2" | pax -r
	rm "$2"
elif ! test -d "$1"; then
	echo "ARGUMENT ${1} IS NEITHER A FILE NOR A DIRECTORY" >&2
	exit 1
fi

set -- "$1" "${1}.tar.gz"

# ValueError: ZIP does not support timestamps before 1980
# 315532800
find "$1" -exec touch -m -t 198001010000 {} \;

pax -w -x ustar "$1" | gzip -9c >"$2"
rm -Rf "$1"

test -f 'SHA256.txt' || touch 'SHA256.txt'
sed "/${2}/d" <'SHA256.txt' >'SHA256.txt.new'
mv SHA256.txt.new SHA256.txt

set -- "$2" $(sha256sum <"$2")
echo "${2}  ${1}" >>'SHA256.txt'
