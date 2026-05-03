[default]
_default:
    @just --list

alias xl := ext-list
alias xi := ext-install

home := home_directory()
config_dir := config_directory()
xdg_config_dir := if env('XDG_CONFIG_HOME', '') =~ '^/' { env('XDG_CONFIG_HOME') } else { home_directory() / '.config' }

# stow only bash configs
[group("shell")]
bash:
    stow bash -t "{{ home }}" --adopt

# stow only zsh configs
[group("shell")]
zsh:
    stow zsh -t "{{ home }}" --adopt

# stow only lazygit [linux]
[group("package")]
[linux]
lazygit:
    stow lazygit -t "{{ xdg_config_dir }}/lazygit" --adopt

# stow only layzgit [macos]
[group("package")]
[macos]
lazygit:
    stow lazygit -t "{{ config_dir }}/lazygit" --adopt

# stow only cobra
[group("extra")]
cobra:
    stow cobra -t "{{ home }}" --adopt

# stow only rustfmt
[group("extra")]
rustfmt:
    stow rustfmt -t "{{ home }}" --adopt

# stow only scripts
[group("extra")]
scripts:
    stow scripts -t "{{ home }}" --adopt

# stow only vscode
[group("package")]
vscode:
    stow vscode -t "{{ config_dir }}" --adopt

# stow only nvim
[group("package")]
nvim:
    stow nvim -t "{{ home }}" --adopt

# stow only starship
[group("package")]
starship:
    stow starship -t "{{ home }}" --adopt

# stow only yazi
[group("package")]
yazi:
    stow yazi -t "{{ home }}" --adopt

# stow only zellij
[group("package")]
zellij:
    stow zellij -t "{{ home }}" --adopt

# stow only ghossty
[group("extra")]
[macos]
ghostty:
    stow ghostty -t "{{ home }}/Library/Application Support/com.mitchellh.ghostty" --adopt

# stow only crush
[group("extra")]
crush:
    stow crush -t "{{ config_dir }}/crush" --adopt

# stow only worktrunk
[group("extra")]
worktrunk:
    stow worktrunk -t "{{ home }}" --adopt

# Install only the extra configurations
[group("bundles")]
extras: cobra rustfmt scripts

# Install only the package configurations
[group("bundles")]
base: lazygit nvim starship yazi zellij

# Install all configurations (base + extra + shell) [macos]
[group("bundles")]
[macos]
stow: zsh base extras

# Install all configurations (base + extra + shell) [linux]
[group("bundles")]
[linux]
stow: bash base extras

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
