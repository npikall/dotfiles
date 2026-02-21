[default]
_default:
    @just --list

alias list := list-extensions
alias install := install-extensions

home := home_directory()
config_dir := config_directory()
xdg_config_dir := if env('XDG_CONFIG_HOME', '') =~ '^/' { env('XDG_CONFIG_HOME') } else { home_directory() / '.config' }

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
[group("package")]
cobra:
    stow cobra -t "{{ home }}" --adopt

# stow only rustfmt
[group("package")]
rustfmt:
    stow rustfmt -t "{{ home }}" --adopt

# stow only scripts
[group("package")]
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

# Install only extra configurations
[group("bundle")]
extras: cobra rustfmt scripts

# Install only basic configurations
[group("bundle")]
base: lazygit nvim starship yazi zellij

# Install all configurations (base + extra + shell) [macos]
[group("bundle")]
[macos]
stow: && base extras
    stow zsh -t "{{ home }}" --adopt

# Install all configurations (base + extra + shell) [linux]
[group("bundle")]
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
