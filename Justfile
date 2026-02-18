[default]
_default:
    @just --list

alias list := list-extensions
alias install := install-extensions

home := home_directory()
config_dir := config_directory()
xdg_config_dir := if env('XDG_CONFIG_HOME', '') =~ '^/' { env('XDG_CONFIG_HOME') } else { home_directory() / '.config' }

# stow only lazygit
[linux]
lazygit:
    stow lazygit -t "{{ xdg_config_dir }}/lazygit" --adopt

# stow only layzgit
[macos]
lazygit:
    stow lazygit -t "{{ config_dir }}/lazygit" --adopt

# Install only extra configurations
extras:
    stow cobra -t "{{ home }}" --adopt
    stow rustfmt -t "{{ home }}" --adopt
    stow scripts -t "{{ home }}" --adopt
    stow vscode -t "{{ config_dir }}"

# Install only basic configurations
base: lazygit
    stow nvim -t "{{ home }}" --adopt
    stow starship -t "{{ home }}" --adopt
    stow yazi -t "{{ home }}" --adopt
    stow zellij -t "{{ home }}" --adopt

# Install all configurations (base + extra + shell) for MacOS
[macos]
stow: && base extras
    stow zsh -t "{{ home }}" --adopt

# Install all configurations (base + extra + shell) for Linux
[linux]
stow: && base extras
    stow bash -t "{{ home }}" --adopt

# Install all extensions saved in vscode-extensions.txt
[group("vscode")]
install-extensions:
    while read -r line; do \
    echo "install $line"; \
    code --install-extension "$line"; \
    done < vscode-extensions.txt

# List all vscode extensions and write them in the extensions file
[group("vscode")]
list-extensions:
    code --list-extensions > vscode-extensions.txt
