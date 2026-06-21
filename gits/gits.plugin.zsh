# gits.plugin.zsh -- zsh wrapper for ~/bin/gits
#
# Drops into ~/.oh-my-zsh/custom/ for zero-config auto-loading. The wrapper
# exists because ~/bin/gits is a child process and cannot change the parent
# shell's PWD on its own -- it prints the resolved path on stdout and this
# function does the actual `cd`.
#
# Exit-code contract from the executable:
#   0 + non-empty stdout : navigation -- cd into it
#   0 + empty stdout     : cancelled picker -- do nothing
#   2 + stdout text      : informational (help, list) -- print it
#   1                    : error -- already on stderr; propagate

# Ensure ~/bin is on PATH so `command gits` resolves the executable. This
# avoids needing a .zshrc edit just to find the binary.
case ":$PATH:" in
    *:"$HOME/bin":*) ;;
    *) export PATH="$HOME/bin:$PATH" ;;
esac

gits() {
    emulate -L zsh
    local out rc
    out=$(command gits "$@")
    rc=$?
    case $rc in
        0)
            [[ -n $out ]] && builtin cd -- "$out"
            ;;
        2)
            [[ -n $out ]] && print -r -- "$out"
            ;;
        *)
            return $rc
            ;;
    esac
}

# Tab completion: complete top-level repo names under $GITS_ROOT.
_gits_complete() {
    local root="${GITS_ROOT:-$HOME/Documents/Gits}"
    local -a repos
    local r
    for r in "$root"/*(/N); do
        repos+=("${r:t}")
    done
    if (( CURRENT == 2 )); then
        _describe 'repo' repos
    fi
}
(( $+functions[compdef] )) && compdef _gits_complete gits
