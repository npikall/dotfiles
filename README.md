# Dotfiles

A collection of my Dotfiles and configs for different applications.

This repo uses [**GNU Stow**][stow] to manage the moving of the dotfiles.
To install the config of a single package just run:

```bash
stow <package>
```

to create the symlinks for the specified package.

Install all configs/dotfiles with:

```bash
just stow
```

This will also stow the rc files for

- `zsh` on `macos`
- `bash` on `linux`

## Dependencies

> [!NOTE]
> There migth be a install script in the future to install everything at once.

You will need to install the following dependencies for a nice experience:

- [`delta`][delta] nicer git diffs in lazygit
- [`gum`][gum] to make shell scripts interactive
- [`just`][just] a taskrunner similar to makefiles
- [`lazygit`][lazygit] a TUI for git written in go
- [`neovim`][nvim] the main code editor
- [`skate`][skate] a key-value store (optional)
- [`starship`][starship] a cross-shell prompt
- [`stow`][stow] to move the dotfiles from this repo to the targets
- [`vscode`][vscode] a code editor (only for Jupyter Notebooks, instead of nvim)
- [`yazi`][yazi] a terminal file manager written in rust
- [`zellij`][zellij] a easy to use terminal multiplexer

## Scripts

There are a couple of Shell Scripts, that are aliased in the `.bashrc`/`.zshrc` files, that will run:

- a pomodoro timer
- a zellij/tmux setup with two tabs, one for development and the other for a server

```bash
just install-extensions
```

[delta]: https://dandavison.github.io/delta/
[gum]: https://github.com/charmbracelet/gum
[just]: https://github.com/casey/just
[lazygit]: https://github.com/jesseduffield/lazygit
[nvim]: https://neovim.io
[skate]: https://github.com/charmbracelet/skate
[starship]: https://starship.rs
[stow]: https://www.gnu.org/software/stow/
[vscode]: https://code.visualstudio.com
[yazi]: https://yazi-rs.github.io
[zellij]: https://zellij.dev
