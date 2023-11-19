#!/usr/bin/env bash

function help {
    echo "Usage: curls [URL]..."
    echo ""
    echo "check a urls aliveness."
    echo ""
    echo "Options:"
    echo "  -s,  --simple            print only the status codes."
    echo "  -n,  --no-delims         print without line delimiters."
    echo "  -h,  --help              print this help."
    exit 1
}

# positional args
NO_DELIMITERS=false
SIMPLE_MODE=false
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
    -s | --simple)
        SIMPLE_MODE=true
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

function remove_dupe_urls() {
    # remove duplicate urls
    urls=()
    for url in "$@"; do
        if [[ ! " ${urls[@]} " =~ " ${url} " ]]; then
            urls+=("$url")
        fi
    done
    echo "${urls[@]}"
}

HEADER_MATCH_STRING='^HTTP|(Location|x-amz-apigw-id|CloudFront|x-amz-cf-id|AmazonS3).*:|Could not resolve host|Content-(Length|Type)'

args=("$@")
urls=($(remove_dupe_urls "${args[@]}"))
index=0
length=${#urls[@]}
final_index=$((length - 1))
exitcode=0

delimiter 50 "-"
for arg in "${urls[@]}"; do
    index=$((index + 1))
    url="$(fang "$arg")"

    echo "> ${url}"
    #response=$(curl --insecure \
    #    --silent \
    #    --fail \
    #    --show-error \
    #    --location  \
    #    --no-progress-meter \
    #    --connect-timeout 30  \
    #    --max-time 120  \
    #    --max-redirs 10  \
    #    --user-agent "$USER_AGENT"  \
    #    --dump-header - \
    #    -o /dev/null \
    #    "$url")
    response=$(curl -kIL --no-progress-meter --connect-timeout 30 --no-keepalive "$url")
    #response="$($cmd)"
    if [ "$?" -ne 0 ]; then
        exitcode=1
    fi

    #output=$(egrep -iE "$HEADER_MATCH_STRING" <<<"$response")
    output=$(egrep -iE "^(HTTP/|Location:)" <<<"$response")
    #output=$(sed -E 's/^Location:/\nLocation:/gi' <<<"$output")
    output=$(sed -E 's/^Location:/\n>>/gi' <<<"$output")

    if [ "$SIMPLE_MODE" = true ]; then
        output=$(sed -E 's/^HTTP\/[0-9.]+ ([0-9]+).*/\1/gi' <<<"$output")
    fi

    if [ "$SIMPLE_MODE" = true ]; then
        echo "$output"
    else
        echo -e "$output"
    fi

    if [ "$index" -eq "$final_index" ]; then
        echo ""
    fi
done
delimiter 50 "-"

exit $exitcode
