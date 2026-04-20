#!/usr/bin/env bash

# Custom install script for neovim

__install_neovim() {
    set -e

    VERSION="latest"
    REPO="neovim/neovim"
    BINARY="nvim"

    need_cmd() {
        if ! command -v "$1" >/dev/null 2>&1; then
            echo "error: need '$1' (command not found)" >&2
            exit 1
        fi
    }

    need_cmd curl
    need_cmd tar
    need_cmd uname

    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    case "$os" in
    linux) os="linux" ;;
    darwin) os="macos" ;;
    *)
        echo "error: unsupported OS: $os" >&2
        exit 1
        ;;
    esac

    case "$arch" in
    x86_64 | amd64) arch="x86_64" ;;
    arm64 | aarch64) arch="arm64" ;;
    *)
        echo "error: unsupported architecture: $arch" >&2
        exit 1
        ;;
    esac

    # Asset name as published on GitHub releases
    # e.g. nvim-linux-x86_64.tar.gz, nvim-macos-arm64.tar.gz
    asset="nvim-${os}-${arch}.tar.gz"

    # GitHub supports a stable redirect for the latest release
    if [ "$VERSION" = "latest" ]; then
        url="https://github.com/${REPO}/releases/latest/download/${asset}"
    else
        url="https://github.com/${REPO}/releases/download/${VERSION}/${asset}"
    fi

    # Find a writable install directory
    install_dir=""
    for dir in "$HOME/.local/bin" "$HOME/.bin" "$HOME/bin" "/usr/local/bin"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            install_dir="$dir"
            break
        fi
    done

    if [ -z "$install_dir" ]; then
        install_dir="$HOME/.local/bin"
        mkdir -p "$install_dir"
    fi

    # Work in a temp directory so we don't leave debris on failure
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading ${asset} (version: ${VERSION}, ${os}/${arch})..."
    curl -fsSL "$url" -o "${tmp_dir}/${asset}"

    echo "Extracting into ${tmp_dir}..."
    tar -xzf "${tmp_dir}/${asset}" -C "$tmp_dir"

    # The tarball unpacks to a directory named after the asset stem,
    # e.g. nvim-linux-x86_64/ with bin/nvim inside
    asset_stem="nvim-${os}-${arch}"
    extracted_bin="${tmp_dir}/${asset_stem}/bin/${BINARY}"

    if [ ! -f "$extracted_bin" ]; then
        echo "error: expected binary not found at ${extracted_bin}" >&2
        exit 1
    fi

    target="${install_dir}/${BINARY}"
    cp "$extracted_bin" "$target"
    chmod +x "$target"

    echo "Installed ${BINARY} to ${target}"

    # Check if install_dir is in PATH
    case ":$PATH:" in
    *":${install_dir}:"*) ;;
    *)
        echo ""
        echo "Note: ${install_dir} is not in your PATH."
        echo "Add it with: export PATH=\"${install_dir}:\$PATH\""
        ;;
    esac
}

__install_neovim
