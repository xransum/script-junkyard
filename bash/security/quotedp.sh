#!/usr/bin/env bash

# help function
help() {
    echo "Usage: quotedp [options] [value]"
    echo "Encode or decode quoted-printable text"
    echo
    echo "Options:"
    echo "  -d                decode quoted-printable text"
    echo "  -i|--interactive  interactive mode"
    echo "  -h                show this help message"
    exit 1
}

# Global variables
INTERACTIVE=0
DECODE=0

# parse arguments
while [ "$1" != "" ]; do
    case $1 in
    -d)
        DECODE=1
        ;;
    -i | --interactive)
        INTERACTIVE=1
        ;;
    -h | --help)
        help
        ;;
    *) break ;;
    esac
    shift
done

# normalize positional parameters
set -- $(echo "$@" | tr -s ' ')
unset values

# function called by action
action() {
    results=
    if [ $DECODE -eq 1 ]; then
        results="$(echo -e "$values" | perl -MMIME::QuotedPrint -ne 'print decode_qp($_)')"
    else
        results="$(echo -e "$values" | perl -MMIME::QuotedPrint -ne 'print encode_qp($_)')"
    fi
    # print output in green
    printf "\e[32m%s\e[0m\n" "$results"
}

# check if interactive mode is enabled
if [ $INTERACTIVE -eq 1 ]; then
    echo "When you are done, press Ctrl+D to exit."
    # read from stdin and set to positional parameters
    set -- "$(</dev/stdin)"
fi

# set value if argument is given
if [ -n "$1" ]; then
    values="$1"
# set value if file is given
elif [ -f "$1" ]; then
    values=$(cat "$1")
# set value if piped
elif [ -p /dev/stdin ]; then
    values=$(cat -)
# else do nothing
else
    values=
fi

# if values is empty show help
if [ -z "$values" ]; then
    help
fi

# execute action
action "$@"
