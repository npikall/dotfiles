# Dotfiles

My personal dotfiles and setup for macOS and Linux: shell configs, editor and
terminal tooling, and the [`git`][git]/[`jj`][jj] setup I use day to day.

Configs are symlinked into place with [**GNU Stow**][stow], driven by a
`Justfile` so each package lands in the right spot — some belong directly in
`$HOME` (`.bashrc`, `.gitconfig`, …), others under `$XDG_CONFIG_HOME` (or its
macOS equivalent).

Day to day: **nvim** for writing code, **jj** for versioning (even on plain
git repos), **zed** as the secondary editor when I'm off nvim, and
**vscode** only when a project needs Jupyter notebooks.

## Installing dependencies

**macOS**, via Homebrew. Install [Homebrew itself][brew-install] first if
you don't have it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The Brewfile also installs a few tools through `uv` (`copier`, `prek`,
`zensical`), so `uv` needs to already be on `PATH` — install it with the
[official installer][uv-install] before running `brew bundle`:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then:

```bash
brew bundle install --file Brewfile
```

**Linux** (or anywhere without Homebrew):

```bash
./install.sh
```

This fetches prebuilt binaries straight from GitHub releases where possible,
falling back to `cargo install`/`go install` (bootstrapping `rustup`/`go`
itself if needed). It also installs `stow`, since that's needed before
anything below will work. Set `INSTALL_DIR` to change where binaries go
(default `~/.local/bin`), or `SKIP_SKATE=1` to skip the `skate` install.

**Nix** isn't covered by either of the above — install it separately with
the [official installer][nix-download]:

```bash
# macOS
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh

# Linux
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

Then `just stow nix` to enable flakes/`nix-command`.

## Stowing the configs

```bash
just list          # show all available packages
just list-bundles   # show bundles and what they contain
just stow <pkg>     # symlink a single package into place
just unstow <pkg>    # remove those symlinks again
just stow-bundle all # stow a whole bundle at once
```

`just list`/`just list-bundles` are the source of truth for what's currently
available — check there rather than relying on this file to enumerate every
package.

A few packages are shell-specific and OS-specific:

- `zsh` is meant for macOS, `bash` for Linux.
- `ghostty` only applies on macOS (`just ghostty`), since it stows straight
  into `~/Library/Application Support/com.mitchellh.ghostty` instead of the
  usual XDG config location.

## What's in here

- **Shells** — `bash`/`zsh` rc files (aliases, prompt, completions).
- **`git`**/**`jj`** — git config plus helpers, and Jujutsu config/cheatsheet.
- **`nvim`** — Neovim config, based on kickstart.nvim.
- **`starship`** — cross-shell prompt.
- **`yazi`** — terminal file manager.
- **`zellij`** — terminal multiplexer, including a `server` layout with
  develop/server/other tabs (aliased as `dev`).
- **`lazygit`** — git TUI config, uses `delta` for diffs.
- **`zed`**, **`vscode`** — editor settings; VS Code is mainly for Jupyter
  notebooks.
- **`ghostty`** — terminal emulator config (macOS only).
- **`nix`** — enables flakes/nix-command.
- **`scripts`** — small helper scripts stowed to `~/scripts` (e.g. the
  pomodoro timer aliased as `pomo`).

[nix-download]: https://nixos.org/download
[brew-install]: https://brew.sh
[uv-install]: https://docs.astral.sh/uv/getting-started/installation/
[git]: https://git-scm.com
[jj]: https://jj-vcs.github.io/jj/
[stow]: https://www.gnu.org/software/stow/
