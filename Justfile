[default]
_default:
    @echo "Home packages: {{ BLUE }}{{ BOLD }}{{ home_pkgs }}{{ NORMAL }}"
    @echo "Config packages: {{ BLUE }}{{ BOLD }}{{ config_pkgs }}{{ NORMAL }}"
    @echo "Bundles: {{ BLUE }}{{ BOLD }}base extras all{{ NORMAL }}"
    @echo ""
    @just --list

alias xl := ext-list
alias xi := ext-install

home := home_directory()
config_dir := config_directory()
xdg_config_dir := if env('XDG_CONFIG_HOME', '') =~ '^/' { env('XDG_CONFIG_HOME') } else { home_directory() / '.config' }
shell_pkg := if os() == "macos" { "zsh" } else { "bash" }

home_pkgs := "bash zsh cobra rustfmt scripts nvim starship yazi zellij git jj pi zed worktrunk"
config_pkgs := "lazygit vscode crush"

base_bundle := "lazygit nvim starship yazi zellij git"
extras_bundle := "cobra rustfmt scripts"
all_bundle := shell_pkg + " " + base_bundle + " " + extras_bundle

# List all available packages
[group("info")]
list:
    #!/usr/bin/env bash
    echo "{{ BOLD }}Home packages:{{ NORMAL }}"
    for pkg in {{ home_pkgs }}; do echo "  {{ BLUE }}{{ BOLD }}$pkg{{ NORMAL}}"; done
    echo ""
    echo "{{ BOLD }}Config packages:{{ NORMAL }}"
    for pkg in {{ config_pkgs }}; do echo "  {{ BLUE }}{{ BOLD }}$pkg{{ NORMAL}}"; done

# List all bundles and their contents
[group("info")]
list-bundles:
    #!/usr/bin/env bash
    echo "{{ BOLD }}base:{{ NORMAL }}   {{ base_bundle }}"
    echo "{{ BOLD }}extras:{{ NORMAL }} {{ extras_bundle }}"
    echo "{{ BOLD }}all:{{ NORMAL }}    {{ all_bundle }}"

# Stow single package to correct location
[group("stow")]
stow pkg:
    #!/usr/bin/env bash
    if echo "{{ home_pkgs }}" | grep -qw "{{ pkg }}"; then
        stow {{ pkg }} --adopt
        echo "{{ GREEN }}{{ BOLD }}Installed{{ NORMAL }}: {{ pkg }}"
    elif echo "{{ config_pkgs }}" | grep -qw "{{ pkg }}"; then
        stow {{ pkg }} -t "{{ config_dir }}" --adopt
        echo "{{ GREEN }}{{ BOLD }}Installed{{ NORMAL }}: {{ pkg }}"
    else
        echo "{{ RED }}{{ BOLD }}Unknown package{{ NORMAL }}: {{ pkg }}"
        echo "Home packages: {{ BLUE }}{{ BOLD }}{{ home_pkgs }}{{ NORMAL }}"
        echo "Config packages: {{ BLUE }}{{ BOLD }}{{ config_pkgs }}{{ NORMAL }}"
        exit 1
    fi

# Unstow single package from correct location
[group("stow")]
unstow pkg:
    #!/usr/bin/env bash
    if echo "{{ home_pkgs }}" | grep -qw "{{ pkg }}"; then
        stow -D {{ pkg }}
        echo "{{ GREEN }}{{ BOLD }}Uninstalled{{ NORMAL }}: {{ pkg }}"
    elif echo "{{ config_pkgs }}" | grep -qw "{{ pkg }}"; then
        stow -D {{ pkg }} -t "{{ config_dir }}"
        echo "{{ GREEN }}{{ BOLD }}Uninstalled{{ NORMAL }}: {{ pkg }}"
    else
        echo "Unknown package: {{ pkg }}"
        echo "Home:   {{ home_pkgs }}"
        echo "Config: {{ config_pkgs }}"
        exit 1
    fi

# Stow bundle of packages (base|extras|all)
[group("bundles")]
stow-bundle name:
    #!/usr/bin/env bash
    case "{{ name }}" in
        base)   pkgs="{{ base_bundle }}" ;;
        extras) pkgs="{{ extras_bundle }}" ;;
        all)    pkgs="{{ all_bundle }}" ;;
        *)      echo "Unknown bundle: {{ name }} (base|extras|all)"; exit 1 ;;
    esac
    for pkg in $pkgs; do
        just stow "$pkg"
    done

# Unstow bundle of packages (base|extras|all)
[group("bundles")]
unstow-bundle name:
    #!/usr/bin/env bash
    case "{{ name }}" in
        base)   pkgs="{{ base_bundle }}" ;;
        extras) pkgs="{{ extras_bundle }}" ;;
        all)    pkgs="{{ all_bundle }}" ;;
        *)      echo "Unknown bundle: {{ name }} (base|extras|all)"; exit 1 ;;
    esac
    for pkg in $pkgs; do
        just unstow "$pkg"
    done

# Stow ghostty config [macos]
[group("stow")]
[macos]
ghostty:
    stow ghostty -t "{{ home }}/Library/Application Support/com.mitchellh.ghostty" --adopt

# Uninstall all extensions saved in vscode-extensions.txt
[group("vscode-extensions")]
ext-uninstall:
    while read -r line; do \
    echo "uninstall $line"; \
    code --uninstall-extension "$line"; \
    done < vscode-extensions.txt

# Install all extensions saved in vscode-extensions.txt
[group("vscode-extensions")]
ext-install:
    while read -r line; do \
    echo "install $line"; \
    code --install-extension "$line"; \
    done < vscode-extensions.txt

# List all vscode extensions and write them in the extensions file
[group("vscode-extensions")]
ext-list file="vscode-extensions.txt":
    code --list-extensions > {{ file }}
