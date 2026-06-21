#!/usr/bin/env bash
# install.sh -- install or update the gits navigator
#
# Run from a local checkout:
#     ./install.sh
#
# Or remotely via curl:
#     curl -fsSL https://raw.githubusercontent.com/xransum/script-junkyard/main/gits/install.sh | bash
#
# Installs (idempotent, backups existing files):
#   ~/bin/gits                              -- the path-resolver executable
#   ~/.oh-my-zsh/custom/gits.plugin.zsh     -- zsh wrapper + completion (if oh-my-zsh present)
#   ~/.bashrc.d/gits.bash                   -- bash wrapper + completion (always; dir auto-created)
#
# Flags:
#   --no-zsh        skip the zsh wrapper
#   --no-bash       skip the bash wrapper
#   --prefix DIR    install the executable to DIR instead of ~/bin
#   --uninstall     remove all installed files
#   --help, -h      this help

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/xransum/script-junkyard/main/gits"

PREFIX="$HOME/bin"
INSTALL_ZSH=1
INSTALL_BASH=1
UNINSTALL=0

log()  { printf "[gits-install] %s\n" "$*"; }
warn() { printf "[gits-install] WARNING: %s\n" "$*" >&2; }
die()  { printf "[gits-install] ERROR: %s\n" "$*" >&2; exit 1; }

print_help() {
    sed -n '2,/^set -e/p' "$0" 2>/dev/null | sed -e 's/^# \{0,1\}//' -e '$d'
    [ -f "$0" ] || cat <<EOF
install.sh -- install or update the gits navigator

Usage: install.sh [--no-zsh] [--no-bash] [--prefix DIR] [--uninstall]
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --no-zsh)   INSTALL_ZSH=0 ;;
        --no-bash)  INSTALL_BASH=0 ;;
        --prefix)   shift; PREFIX="$1" ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help)  print_help; exit 0 ;;
        *)          die "unknown flag: $1" ;;
    esac
    shift
done

# Detect whether we have a local checkout (script lives next to source files).
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    candidate=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    if [ -f "$candidate/gits" ] && [ -f "$candidate/gits.plugin.zsh" ]; then
        SCRIPT_DIR="$candidate"
    fi
fi

fetch() {
    local name="$1" dest="$2"
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$name" ]; then
        cp "$SCRIPT_DIR/$name" "$dest"
    else
        if ! command -v curl >/dev/null 2>&1; then
            die "curl not found; install curl or run install.sh from a local checkout"
        fi
        curl -fsSL "$REPO_RAW/$name" -o "$dest"
    fi
}

backup_if_exists() {
    local path="$1"
    if [ -f "$path" ]; then
        local bak="${path}.bak.$(date +%Y%m%d%H%M%S)"
        cp "$path" "$bak"
        log "backed up existing $(basename "$path") -> $(basename "$bak")"
    fi
}

install_executable() {
    local dest="$PREFIX/gits"
    mkdir -p "$PREFIX"
    backup_if_exists "$dest"
    fetch gits "$dest"
    chmod +x "$dest"
    log "installed executable: $dest"
}

install_zsh_wrapper() {
    if [ ! -d "$HOME/.oh-my-zsh/custom" ]; then
        warn "oh-my-zsh custom dir not found; skipping zsh wrapper"
        warn "  (manual install: source the wrapper from your .zshrc)"
        return 0
    fi
    local dest="$HOME/.oh-my-zsh/custom/gits.plugin.zsh"
    backup_if_exists "$dest"
    fetch gits.plugin.zsh "$dest"
    log "installed zsh wrapper: $dest (auto-loaded by oh-my-zsh)"
}

install_bash_wrapper() {
    local bashrc_d="$HOME/.bashrc.d"
    if [ ! -d "$bashrc_d" ]; then
        # Fedora-style ~/.bashrc auto-sources ~/.bashrc.d/* when present.
        # Creating the dir is enough; no .bashrc edit required.
        mkdir -p "$bashrc_d"
        log "created $bashrc_d (your .bashrc auto-sources files placed here)"
    fi
    local dest="$bashrc_d/gits.bash"
    backup_if_exists "$dest"
    fetch gits.bash "$dest"
    log "installed bash wrapper: $dest"

    # Verify .bashrc actually sources .bashrc.d (Fedora/RHEL default; others may not)
    if [ -f "$HOME/.bashrc" ] && ! grep -q "bashrc.d" "$HOME/.bashrc" 2>/dev/null; then
        warn ".bashrc does not appear to auto-source ~/.bashrc.d/"
        warn "  add this snippet to ~/.bashrc to enable:"
        warn "    if [ -d ~/.bashrc.d ]; then"
        warn "      for rc in ~/.bashrc.d/*; do [ -f \"\$rc\" ] && . \"\$rc\"; done"
        warn "      unset rc"
        warn "    fi"
    fi
}

path_check() {
    case ":$PATH:" in
        *":$PREFIX:"*) ;;
        *)
            warn "$PREFIX is not currently on your PATH"
            warn "  the wrappers add it automatically when sourced, but if you"
            warn "  call \`gits\` from a shell without the wrapper loaded, it"
            warn "  will not be found. Consider adding to your shell startup:"
            warn "    export PATH=\"$PREFIX:\$PATH\""
            ;;
    esac
}

uninstall() {
    local removed=0
    for path in \
        "$PREFIX/gits" \
        "$HOME/.oh-my-zsh/custom/gits.plugin.zsh" \
        "$HOME/.bashrc.d/gits.bash"
    do
        if [ -f "$path" ]; then
            rm -f "$path"
            log "removed $path"
            removed=$((removed + 1))
        fi
    done
    log "uninstall complete ($removed file(s) removed)"
    log "leftover state file (if any): $HOME/.local/state/gits/"
}

main() {
    if [ "$UNINSTALL" -eq 1 ]; then
        uninstall
        exit 0
    fi

    install_executable
    [ "$INSTALL_ZSH" -eq 1 ]  && install_zsh_wrapper
    [ "$INSTALL_BASH" -eq 1 ] && install_bash_wrapper
    path_check

    cat <<EOF

Installation complete. To activate immediately:
  zsh:  exec zsh
  bash: exec bash

Then try:
  gits                # cd to ~/Documents/Gits
  gits valk           # cd to valkyrie-tools (substring match)
  gits ls             # list repos
  gits -h             # full help
EOF
}

main "$@"
