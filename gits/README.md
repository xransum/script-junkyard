# gits

A fuzzy `cd` for the directory you keep all your git checkouts in.

```
$ gits                 # cd to your gits root (~/Documents/Gits by default)
$ gits valk            # cd to valkyrie-tools (case-insensitive substring match)
$ gits pa              # multiple matches -> picks via fzf if installed,
                       # else a numbered menu (pack-ripper, panopticon, ...)
$ gits -               # toggle back to the previous repo (like `cd -`)
$ gits ls              # list every repo
$ gits -h              # full help
```

Tab completion fills in repo names.

## Install

One-liner via curl:

```sh
curl -fsSL https://raw.githubusercontent.com/xransum/script-junkyard/main/gits/install.sh | bash
```

Or from a local checkout:

```sh
git clone https://github.com/xransum/script-junkyard.git
./script-junkyard/gits/install.sh
```

The installer drops three files:

| File | Purpose |
|---|---|
| `~/bin/gits` | the path-resolver executable |
| `~/.oh-my-zsh/custom/gits.plugin.zsh` | zsh wrapper + completion (auto-loaded by oh-my-zsh) |
| `~/.bashrc.d/gits.bash` | bash wrapper + completion (auto-loaded by Fedora-style `.bashrc`) |

No `.zshrc` or `.bashrc` edits required. Each wrapper prepends `~/bin` to `PATH`
on load, so the executable resolves cleanly.

Skip a shell or override the install prefix:

```sh
./install.sh --no-bash              # zsh only
./install.sh --no-zsh               # bash only
./install.sh --prefix ~/.local/bin  # different binary location
./install.sh --uninstall            # remove everything
```

## Configuration

Set `GITS_ROOT` to point at a different repo directory:

```sh
export GITS_ROOT=~/code
```

State (the "previous repo" used by `gits -`) is kept in
`${XDG_STATE_HOME:-~/.local/state}/gits/last`.

## Why a wrapper function instead of just an executable?

`cd` is a shell builtin -- a child process cannot change its parent's working
directory (this is hard OS-level isolation, not a shell quirk). So any
directory-changer tool needs at least one shell-side piece. The split here:

- `~/bin/gits` does all the real work: matching, picker, state. Prints the
  resolved path on stdout.
- The wrapper function (4 lines plus completion) captures that stdout and runs
  the actual `cd`. Same pattern as `zoxide`, `direnv`, `nvm`, etc.

This means you can also use the raw executable in scripts:

```sh
cd "$(gits valk)"             # if you bypass the wrapper for some reason
target=$(gits panopt) && cd "$target"
```

## Exit-code contract

The executable signals the wrapper via exit code:

| Exit | stdout | Wrapper does |
|------|--------|--------------|
| 0 | resolved path | `cd` to it |
| 0 | empty | nothing (cancelled picker) |
| 2 | help / list text | print to user |
| 1 | (empty; error on stderr) | propagate the failure |

## Files

- [`gits`](./gits) -- the bash executable
- [`gits.plugin.zsh`](./gits.plugin.zsh) -- zsh wrapper
- [`gits.bash`](./gits.bash) -- bash wrapper
- [`install.sh`](./install.sh) -- installer
