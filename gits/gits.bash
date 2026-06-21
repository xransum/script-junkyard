# gits.bash -- bash wrapper for ~/bin/gits
#
# Drops into ~/.bashrc.d/ for auto-loading by the snippet at the bottom of
# Fedora-style ~/.bashrc files. If your .bashrc does not auto-source that
# dir, add this line to it:
#     [ -r ~/.bashrc.d/gits.bash ] && . ~/.bashrc.d/gits.bash
#
# The wrapper exists because ~/bin/gits is a child process and cannot change
# the parent shell's PWD on its own -- it prints the resolved path on stdout
# and this function does the actual `cd`.

# Ensure ~/bin is on PATH so `command gits` resolves the executable.
case ":$PATH:" in
    *:"$HOME/bin":*) ;;
    *) export PATH="$HOME/bin:$PATH" ;;
esac

gits() {
    local out rc
    out=$(command gits "$@")
    rc=$?
    case $rc in
        0)
            [ -n "$out" ] && builtin cd -- "$out"
            ;;
        2)
            [ -n "$out" ] && printf "%s\n" "$out"
            ;;
        *)
            return $rc
            ;;
    esac
}

# Tab completion: complete top-level repo names under $GITS_ROOT.
_gits_complete() {
    local root="${GITS_ROOT:-$HOME/Documents/Gits}"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local -a repos=()
    local d
    if [ "$COMP_CWORD" -eq 1 ]; then
        for d in "$root"/*/; do
            [ -d "$d" ] || continue
            repos+=("$(basename "$d")")
        done
        # shellcheck disable=SC2207
        COMPREPLY=( $(compgen -W "${repos[*]}" -- "$cur") )
    fi
}
complete -F _gits_complete gits 2>/dev/null
