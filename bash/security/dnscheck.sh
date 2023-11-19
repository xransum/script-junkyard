#!/usr/bin/env bash

function help {
    echo "Usage: dnscheck [DOMAIN|IP]..."
    echo ""
    echo "domain name system lookup, equivalent to 'host DOMAIN'"
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

function extract_domain() {
    value="$1"
    if [[ "$value" == *"://"* ]]; then
        awk -F/ '{print $3}' <<<"$value"
    else
        echo "$value"
    fi
}

args=("$@")
args=($(remove_dupes "${args[@]}"))
index=0
length=${#args[@]}
final_index=$((length - 1))
exitcode=0

for arg in "${args[@]}"; do
    arg="$(fang "$arg")"
    arg="$(extract_domain "$arg")"

    echo "> $arg"

    #output="$(dig +short $arg | sort -n)"
    #output="$(host "$arg" 2>&1)"
    output=""
    # record types that will give us an ip addr or a ptr record
    record_types=("A" "AAAA" "PTR")
    for record_type in "${record_types[@]}"; do
        if [[ "$record_type" == "PTR" ]]; then
            result="$(dig -x "$arg" +short)"
        else
            result="$(dig "$arg" "$record_type" +short)"
        fi

        # capture return code
        if [[ "$?" -ne 0 ]]; then
            exitcode=1
        fi
        
        if [[ "$result" ]]; then
            # append the record type to each line of output
            result="$(sed "s/$/ [$record_type]/g" <<<"$result")"
            output="$output$result"
        fi
    done

    if [[ "$output" ]]; then
        echo "$output"
    else
        echo "No DNS results found."
    fi
    
    if [[ "$index" -ne "$final_index" ]]; then
        echo ""
    fi

    index=$((index + 1))
done

exit $exitcode
