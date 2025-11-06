# dotfiles

A collection of my private Dotfiles and configs for different applications.

This repo uses **GNU Stow** to manage the symlinks.
Just run

```bash
stow <package>
```

to create the symlinks for the specified package.

In order to update the `vscode-extensions.txt` file run the following:

```bash
code --list-extensions > vscode-extensions.txt
```

The Extensions listed here can be installed via the `Justfile` with:

```bash
just extensions
```

## Dependencies

> [!IMPORTANT]
> Listed dependencies are probably incomplete.

- `stow`
- `ya` `yazi`
- `lazygit`
- `vscode`
- `git-delta`
