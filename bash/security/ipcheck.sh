#!/usr/bin/env bash

function help {
    echo "Usage: ipcheck [IP]..."
    echo ""
    echo "check ip address info."
    echo ""
    echo "Options:"
    echo "  -n,  --no-delims         print without line delimiters."
    echo "  -h,  --help              print this help."
    exit 1
}

# positional args
NO_DELIMITERS=false
args=()
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -h | --help)
        help
        exit 1
        ;;
    -n | --no-delims)
        NO_DELIMITERS=true
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

# ensure the fang script is installed
if ! command -v fang &>/dev/null; then
    echo "fang command could not be found!"
    exit 2
fi

function delimiter() {
    nchars="$1"
    char="$2"
    if [ "$NO_DELIMITERS" = true ]; then
        echo -n ""
    else
        printf "%${nchars}s\n" | tr " " "$char"
    fi
}

function remove_dupes() {
        values=()
        for value in "$@"; do
                if [[ ! " ${values[@]} " =~ " ${value} " ]]; then
                        values+=("$value")
                fi
        done
        echo "${values[@]}"
}

EXCLUDE_KEYS=("readme" "ip")

args=("$@")
args=($(remove_dupes "${args[@]}"))
index=0
length=${#args[@]}
final_index=$((length - 1))
exitcode=0

delimiter 50 "-"
for arg in "${args[@]}"; do
        arg="$(fang "$arg")"

        echo "> ${arg}"

        results="$(curl -skL "https://ipinfo.io/${arg}/json")"
        if [ -z "$results" ]; then
                echo "No results found for ${arg}!"
                exitcode=1
                continue
        fi

        for key in $(echo "$results" | jq -r 'keys | .[]'); do
                if [[ " ${EXCLUDE_KEYS[@]} " =~ " ${key} " ]]; then
                        continue
                fi

                value="$(jq -r ".${key}" <<<"$results")"

                # pad left of key
                printf "  %-10s%s\n" "${key}:" "${value}"
        done

        if [ "$index" -ne "$final_index" ]; then
                echo ""
        fi

        index=$((index + 1))
done
delimiter 50 "-"

exit $exitcode
