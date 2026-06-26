#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-${HOME}/.local/bin}"
GO_ROOT="${HOME}/.local/go"
mkdir -p "${INSTALL_DIR}"
export PATH="${INSTALL_DIR}:${HOME}/.cargo/bin:${PATH}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

_ok()   { echo -e "${GREEN}✓${NC} $*"; }
_skip() { echo -e "${YELLOW}–${NC} $1 already installed, skipping"; }
_err()  { echo -e "${RED}✗${NC} $*" >&2; }
_info() { echo -e "${BLUE}→${NC} $*"; }

is_installed() { command -v "$1" &>/dev/null; }

# --- Platform ---

get_os() {
    case "$(uname -s)" in
        Linux)  echo "linux" ;;
        Darwin) echo "macos" ;;
        *) _err "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac
}

get_arch() {
    case "$(uname -m)" in
        x86_64)        echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        *) _err "Unsupported arch: $(uname -m)"; exit 1 ;;
    esac
}

# Rust musl target triple
get_target() {
    case "$(get_os)-$(get_arch)" in
        linux-x86_64)   echo "x86_64-unknown-linux-musl" ;;
        linux-aarch64)  echo "aarch64-unknown-linux-musl" ;;
        macos-x86_64)   echo "x86_64-apple-darwin" ;;
        macos-aarch64)  echo "aarch64-apple-darwin" ;;
    esac
}

# Capitalized OS for charmbracelet-style releases (Linux / Darwin)
get_OS() {
    case "$(get_os)" in
        linux) echo "Linux" ;;
        macos) echo "Darwin" ;;
    esac
}

# arm64 variant for Go-style releases (x86_64 / arm64)
get_arch64() {
    case "$(get_arch)" in
        x86_64)  echo "x86_64" ;;
        aarch64) echo "arm64" ;;
    esac
}

# Go arch (amd64 / arm64)
get_goarch() {
    case "$(get_arch)" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
    esac
}

# --- GitHub release helper ---

latest_tag() {
    curl -sfL "https://api.github.com/repos/${1}/releases/latest" \
        | grep '"tag_name"' \
        | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
}

strip_v() { echo "${1#v}"; }

gh_install() {
    local repo="$1" bin="$2" url_pattern="$3"
    local tag version target OS arch64 url tmp

    tag=$(latest_tag "$repo")
    version=$(strip_v "$tag")
    target=$(get_target)
    OS=$(get_OS)
    arch64=$(get_arch64)

    url="${url_pattern}"
    url="${url/\{tag\}/${tag}}"
    url="${url/\{version\}/${version}}"
    url="${url/\{target\}/${target}}"
    url="${url/\{OS\}/${OS}}"
    url="${url/\{arch64\}/${arch64}}"

    tmp=$(mktemp -d)
    trap 'rm -rf "${tmp}"' RETURN

    _info "Downloading ${bin} ${tag}..."
    curl -fsSL "$url" -o "${tmp}/archive"

    case "$url" in
        *.tar.gz|*.tgz) tar -xzf "${tmp}/archive" -C "${tmp}" ;;
        *.tar.xz)        tar -xJf "${tmp}/archive" -C "${tmp}" ;;
        *.zip)           unzip -q "${tmp}/archive" -d "${tmp}" ;;
    esac

    find "${tmp}" -name "$bin" -type f \
        -exec install -m755 {} "${INSTALL_DIR}/${bin}" \;
}

# --- Compiler setup ---

_install_rustup() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "${HOME}/.cargo/env"
    export PATH="${HOME}/.cargo/bin:${PATH}"
}

_install_go() {
    local goos goarch version url tmp
    goos=$(get_os)
    [[ "$goos" == "macos" ]] && goos="darwin"
    goarch=$(get_goarch)
    version=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)
    url="https://go.dev/dl/${version}.${goos}-${goarch}.tar.gz"

    tmp=$(mktemp -d)
    trap 'rm -rf "${tmp}"' RETURN

    _info "Downloading Go ${version}..."
    curl -fsSL "$url" -o "${tmp}/go.tar.gz"
    rm -rf "${GO_ROOT}"
    mkdir -p "$(dirname "${GO_ROOT}")"
    tar -xzf "${tmp}/go.tar.gz" -C "${tmp}"
    mv "${tmp}/go" "${GO_ROOT}"
    ln -sf "${GO_ROOT}/bin/go" "${INSTALL_DIR}/go"
    ln -sf "${GO_ROOT}/bin/gofmt" "${INSTALL_DIR}/gofmt"
}

ensure_rust() {
    if ! is_installed cargo; then
        _info "Rust not found, installing via rustup..."
        _install_rustup && _ok "rust (rustup)"
    fi
}

ensure_go() {
    if ! is_installed go; then
        _info "Go not found, installing from go.dev..."
        _install_go && _ok "go"
    fi
}

ensure_cargo_binstall() {
    if ! is_installed cargo-binstall; then
        _info "Installing cargo-binstall..."
        curl -L --proto '=https' --tlsv1.2 -sSf \
            https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh \
            | bash
    fi
}

# --- Generic installers ---

# Rust tool: GH release → cargo install fallback
try_rust() {
    local bin="$1" repo="$2" url_pattern="$3" crate="${4:-}"
    if is_installed "$bin"; then _skip "$bin"; return; fi

    ensure_rust
    _info "Installing ${bin}..."

    if gh_install "$repo" "$bin" "$url_pattern" 2>/dev/null; then
        _ok "${bin} (github release)"
    elif [[ -n "$crate" ]] && is_installed cargo; then
        cargo install "$crate" \
            && ln -sf "${HOME}/.cargo/bin/${bin}" "${INSTALL_DIR}/${bin}" \
            && _ok "${bin} (cargo install)"
    else
        _err "Failed to install ${bin}"
    fi
}

# Go tool: GH release → go install fallback
try_go() {
    local bin="$1" repo="$2" url_pattern="$3" go_pkg="${4:-}"
    if is_installed "$bin"; then _skip "$bin"; return; fi

    ensure_go
    _info "Installing ${bin}..."

    if gh_install "$repo" "$bin" "$url_pattern" 2>/dev/null; then
        _ok "${bin} (github release)"
    elif [[ -n "$go_pkg" ]] && is_installed go; then
        GOBIN="${INSTALL_DIR}" go install "${go_pkg}@latest" \
            && _ok "${bin} (go install)"
    else
        _err "Failed to install ${bin}"
    fi
}

# --- Individual installers ---

install_stow() {
    if is_installed stow; then _skip stow; return; fi

    _info "Installing stow..."
    if is_installed apt-get; then
        sudo apt-get install -y stow && _ok "stow (apt)"
    elif is_installed brew; then
        brew install stow && _ok "stow (brew)"
    else
        _err "Cannot install stow: no apt or brew found. Install manually: https://www.gnu.org/software/stow/"
    fi
}

install_neovim() {
    if is_installed nvim; then _skip nvim; return; fi

    local os arch tag url dir tmp
    os=$(get_os); arch=$(get_arch)
    tag=$(latest_tag "neovim/neovim")

    case "${os}-${arch}" in
        linux-x86_64)   url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-linux-x86_64.tar.gz"; dir="nvim-linux-x86_64" ;;
        linux-aarch64)  url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-linux-arm64.tar.gz";  dir="nvim-linux-arm64"  ;;
        macos-x86_64)   url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-macos-x86_64.tar.gz"; dir="nvim-macos-x86_64" ;;
        macos-aarch64)  url="https://github.com/neovim/neovim/releases/download/${tag}/nvim-macos-arm64.tar.gz";  dir="nvim-macos-arm64"  ;;
        *) _err "Unsupported platform for neovim: ${os}-${arch}"; return 1 ;;
    esac

    tmp=$(mktemp -d)
    trap 'rm -rf "${tmp}"' RETURN

    # Extract full tarball to a prefix dir so neovim can locate its runtime
    # relative to the real binary path (nvim resolves symlinks for VIMRUNTIME).
    local nvim_prefix="${HOME}/.local/nvim"
    _info "Downloading neovim ${tag}..."
    curl -fsSL "$url" -o "${tmp}/nvim.tar.gz"
    tar -xzf "${tmp}/nvim.tar.gz" -C "${tmp}"
    rm -rf "${nvim_prefix}"
    mv "${tmp}/${dir}" "${nvim_prefix}"
    ln -sf "${nvim_prefix}/bin/nvim" "${INSTALL_DIR}/nvim"
    _ok "nvim (github release)"
}

install_yazi() {
    if is_installed yazi; then _skip yazi; return; fi

    ensure_rust
    ensure_cargo_binstall

    _info "Installing yazi + ya via cargo-binstall..."
    cargo binstall --no-confirm yazi-fm yazi-cli \
        && ln -sf "${HOME}/.cargo/bin/yazi" "${INSTALL_DIR}/yazi" \
        && ln -sf "${HOME}/.cargo/bin/ya" "${INSTALL_DIR}/ya" \
        && _ok "yazi + ya (cargo-binstall)"
}

# --- Main ---

echo ""
echo "Installing dotfile dependencies"
echo "  INSTALL_DIR : ${INSTALL_DIR}"
echo "  GO_ROOT     : ${GO_ROOT}"
echo "================================"
echo ""

install_stow

try_rust "delta"    "dandavison/delta"     \
    "https://github.com/dandavison/delta/releases/download/{tag}/delta-{version}-{target}.tar.gz" \
    "git-delta"

try_rust "just"     "casey/just"           \
    "https://github.com/casey/just/releases/download/{tag}/just-{version}-{target}.tar.gz" \
    "just"

try_rust "starship" "starship-rs/starship" \
    "https://github.com/starship/starship/releases/download/{tag}/starship-{target}.tar.gz" \
    "starship"

try_rust "zoxide"   "ajeetdsouza/zoxide"   \
    "https://github.com/ajeetdsouza/zoxide/releases/download/{tag}/zoxide-{version}-{target}.tar.gz" \
    "zoxide"

try_rust "zellij"   "zellij-org/zellij"   \
    "https://github.com/zellij-org/zellij/releases/download/{tag}/zellij-{target}.tar.gz" \
    "zellij"

install_yazi

try_go "gum"     "charmbracelet/gum"     \
    "https://github.com/charmbracelet/gum/releases/download/{tag}/gum_{version}_{OS}_{arch64}.tar.gz" \
    "github.com/charmbracelet/gum"

try_go "lazygit" "jesseduffield/lazygit" \
    "https://github.com/jesseduffield/lazygit/releases/download/{tag}/lazygit_{version}_{OS}_{arch64}.tar.gz" \
    "github.com/jesseduffield/lazygit"

if [[ "${SKIP_SKATE:-0}" != "1" ]]; then
    try_go "skate" "charmbracelet/skate" \
        "https://github.com/charmbracelet/skate/releases/download/{tag}/skate_{version}_{OS}_{arch64}.tar.gz" \
        "github.com/charmbracelet/skate"
else
    _skip "skate (SKIP_SKATE=1)"
fi

install_neovim

echo ""
_ok "Done! Ensure these are in your PATH:"
echo ""
echo "  export PATH=\"${INSTALL_DIR}:\${HOME}/.cargo/bin:\${PATH}\""
echo ""
