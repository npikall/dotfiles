# Dotfiles, symlinked into place with GNU Stow.
#
# Every top-level directory is a package that gets linked into ~.
# Exceptions (other targets, bundles) live in packages.conf.
# The logic lives in lib/*.sh; recipes here only call it.

alias xi := ext-install
alias xl := ext-list

# Show packages, bundles and recipes
[private]
default:
    @lib/info.sh summary
    @just --list --unsorted

# List all packages and where they get linked
[group("info")]
list:
    @lib/info.sh list

# List all bundles and their packages
[group("info")]
list-bundles:
    @lib/info.sh bundles

# Show installed, missing and stale packages
[group("info")]
status:
    @lib/status.sh

# Link packages, e.g. just stow nvim git
[group("stow")]
stow +pkgs:
    @lib/stow.sh link {{ pkgs }}

# Unlink packages, e.g. just unstow nvim git
[group("stow")]
unstow +pkgs:
    @lib/stow.sh unlink {{ pkgs }}

# Link a bundle, e.g. just stow-bundle base
[group("bundles")]
stow-bundle name:
    @lib/stow.sh link-bundle {{ name }}

# Unlink a bundle, e.g. just unstow-bundle base
[group("bundles")]
unstow-bundle name:
    @lib/stow.sh unlink-bundle {{ name }}

# Install all extensions listed in the file
[group("vscode")]
ext-install file="vscode-extensions.txt":
    @while read -r ext; do echo "install $ext"; code --install-extension "$ext"; done < {{ file }}

# Uninstall every installed extension
[group("vscode")]
ext-uninstall:
    @code --list-extensions | while read -r ext; do echo "uninstall $ext"; code --uninstall-extension "$ext" --force; done

# Write installed extensions to the file
[group("vscode")]
ext-list file="vscode-extensions.txt":
    code --list-extensions --show-versions > {{ file }}
