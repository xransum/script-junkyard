#!/usr/bin/env bash

function help {
        echo "Usage: curls [URL]..."
        echo ""
        echo "check a urls aliveness."
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

HEADER_MATCH_STRING='^HTTP|(Location|x-amz-apigw-id|CloudFront|x-amz-cf-id|AmazonS3).*:|Could not resolve host|Content-(Length|Type)'

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
        #    "$arg")
        response="$(curl -kIL --no-progress-meter --connect-timeout 30 --no-keepalive --show-error --fail --silent "$arg" 2>&1)"
        #response="$($cmd)"
        if [ "$?" -ne 0 ]; then
                exitcode=1
        fi

        #output=$(egrep -iE "$HEADER_MATCH_STRING" <<<"$response")
        output=$(egrep -iE "^(HTTP/|Location:)" <<<"$response")
        #output=$(sed -E 's/^Location:/\nLocation:/gi' <<<"$output")
        output=$(sed -E 's/^Location:/\n>>/gi' <<<"$output")

        # print output and trim trailing whitespace
        echo "$output" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba'

        # print error
        reason="$(grep -oP 'curl:.*$' <<<"$response")"
        if [[ "$reason" == *"Could not resolve host"* ]]; then
                echo "Could not resolve host."
        elif [[ "$reason" == *"Connection timed out"* ]]; then
                echo "Connection timed out."
        elif [[ "$reason" == *"Failed to connect to"* ]]; then
                grep -oP 'Failed to connect to.*$' <<<"$reason" |
                        sed 's/to .\+\? port/to connect to port/g' |
                        sed 's/ after.*/./g'
        else
                echo "Unknown error."
                echo "$reason"
        fi

        if [ "$index" -ne "$final_index" ]; then
                echo ""
        fi

        index=$((index + 1))
done
delimiter 50 "-"

exit $exitcode
