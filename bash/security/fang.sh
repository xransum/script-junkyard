#!/usr/bin/env bash

function help {
    echo "Usage: fang [TEXT]..."
    echo ""
    echo "Refang or defang urls, ip addresses, domains, and emails."
    echo ""
    echo "Options:"
    echo "  -h,  --help              print this help."
    exit 1
}

function refang_text() {
    echo "$@" |
        # remove spaces
        sed 's/ //g' |
        # replace [.] with .
        sed 's/\[\+\.\]\+/./g' |
        # replace [dot], (dot), or [DOT] with .
        sed 's/\[\+[dot]\]\+\|\(dot\)/./gi' |
        # replace [://], [:]// with ://
        sed 's/\[\+:\/\/\]\+\|\[:\]\/\//:\/\//g' |
        # replace hxxp with http
        sed -E 's/h[tx][tx]p(s)?/http\1/gi;' |
        # replace fxp with ftp, fxxs with ftps
        sed -E 's/f[tx][tx]p(s)?/ftp\1/gi;' |
        # replace [at], (at), or [AT] with @
        sed 's/\[\+at\]\+\|\(at\)/@/gi'
}

function defang_text() {
    echo "$@" |
        # replace . with [.]
        sed 's/\./[.]/g' |
        # replace :// with [://]
        sed 's/:\/\//[:\/\/]/g' |
        # replace http with hxxp
        sed -E 's/http(s)?/hxxp\1/gi;' |
        # replace ftp with fxp, ftps with fxxs
        sed -E 's/ftp(s)?/fxp\1/gi;' |
        # replace @ with [at]
        sed 's/@/[at]/g'
}

# positional args
defang=false
args=()
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help)
        help
        exit 1
        ;;
    -d | --defang)
        defang=true
        shift
        ;;
    -* | --*)
        shift
        ;;
    *)
        args+=("$1")
        shift
        ;;
    esac
done

# set value if file is given
if [ -p /dev/stdin ]; then
    args+=("$(cat -)")
fi

# recover positional args
set -- "${args[@]}"

# exit with no args
if [ -z "$1" ]; then
    help
fi

if [ "$defang" = true ]; then
    defang_text "$@"
else
    refang_text "$@"
fi

exit 0
