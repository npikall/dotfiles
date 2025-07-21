is-wsl := `uname -a | grep -qi microsoft && echo true || echo false`

# TODO: Fix the path variables !!!
vsc-wsl := "/mnt/User/AppData/Roaming/Code/User/"
vsc-win := "~/AppData/Roaming/Code/User/"
vsc-mac := "~/Library/Application Support/Code/User/"

vscode-target := if os() == "linux" {
    if is-wsl == "true" {
        vsc-wsl
    } else {
        vsc-mac
    }
} else if os() == "windows" {
    vsc-win
} else {
    vsc-mac
}

[private]
default:
    @just --list

# Install vscode
vscode:
    @echo "{{ vscode-target }}"
    stow just --target="{{ vscode-target }}"
    @echo "{{GREEN}}VSCode installed {{NORMAL}}"

# Install all packages for MacOS (bash)
[macos]
all:
    @echo "Install all on mac"
    stow zsh -t ~/
    stow nvim -t ~/
    stow yazi -t ~/
    @echo "{{GREEN}}All installed {{NORMAL}}"

# Install all packages for Linux (zsh)
[linux]
all:
    @echo "Install all on linux"
    stow nvim -t ~/
    stow yazi -t ~/
    stow bash -t ~/
    @echo "{{GREEN}}All installed {{NORMAL}}"