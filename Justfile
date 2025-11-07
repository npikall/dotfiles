[private]
default:
    @just --list


# Stow all packages that are not shell/platform specific
stow-all:
    @echo "{{ GREEN }}Install all packages{{ NORMAL }}"
    stow lazygit -t ~/
    stow nvim -t ~/
    stow rustfmt -t ~/
    stow yazi -t ~/
    @echo "{{ GREEN }}All installed {{ NORMAL }}"


# Install all packages for MacOS
[macos]
platform:
    @echo "{{ GREEN }}Install for Linux{{ NORMAL }}"
    stow vscode -t ~/
    @echo "{{ GREEN }}All installed {{ NORMAL }}"


# Install all packages for Linux
[linux]
platform:
    @echo "{{ GREEN }}Install for MacOS{{ NORMAL }}"
    stow vscode-linux -t ~/
    @echo "{{ GREEN }}All installed {{ NORMAL }}"


# Install all extensions saved in vscode-extensions.txt
extensions:
    set -euo pipefail
    #!/usr/bin/env bash

    cat vscode-extensions.txt | while read extension || [[ -n $extension ]];
    do
    echo "Install $extension"
    code --install-extension "$extension" --force
    done

# List all vscode extensions and pipe them in the extensions file
ext-list:
	code --list-extensions > vscode-extensions.txt
