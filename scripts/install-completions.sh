#!/usr/bin/env bash
#
# Generate shell completions for installed CLI tools.
#
# Usage: install-completions.sh [zsh|bash|fish]   (default: basename of $SHELL)
#
# Tools that aren't installed are logged and skipped. Set COMPLETIONS_DIR to
# override the target directory.
#
# Not listed: eza, yazi and git-cliff have no generator (Homebrew ships their
# files), fzf and zoxide use `init` in .zshrc, lazygit only generates flags.
set -euo pipefail

TOOLS=(
    # Required
    cargo gh gotpm rex typst uv jj
    # Extras
    bat delta fd glab golangci-lint goreleaser gum hugo just prek rg rustup
    skate starship task uvx zellij zizmor
)

# Same locations a login shell has, so a bare environment doesn't skip tools.
# rex is only on PATH inside Rex panes, hence its app bundle.
export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${HOME}/go/bin:${HOME}/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS:${PATH}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

_ok()   { echo -e "${GREEN}✓${NC} $*"; }
_skip() { echo -e "${YELLOW}–${NC} $*"; }
_err()  { echo -e "${RED}✗${NC} $*" >&2; }
_info() { echo -e "${BLUE}→${NC} $*"; }

# clap's dynamic zsh script only registers itself with compdef. Autoloaded from
# fpath that would swallow the first TAB, so also run the completer on load.
clap_dynamic() {
    local tool="$1" shell="$2"
    COMPLETE="$shell" "$tool" || return
    if [[ "$shell" == zsh ]]; then
        printf '\nif [ "$funcstack[1]" = "_%s" ]; then\n  _clap_dynamic_completer_%s "$@"\nfi\n' "$tool" "$tool"
    fi
}

# Print the completion script for a tool to stdout.
generate() {
    local tool="$1" shell="$2"
    case "$tool" in
        cargo)    rustup completions "$shell" cargo ;;
        rustup)   rustup completions "$shell" ;;
        gh|glab)  "$tool" completion -s "$shell" ;;
        gotpm|rex|golangci-lint|goreleaser|gum|hugo|skate)
                  "$tool" completion "$shell" ;;
        jj|prek)  clap_dynamic "$tool" "$shell" ;;
        typst|starship)
                  "$tool" completions "$shell" ;;
        uv)       uv generate-shell-completion "$shell" ;;
        uvx)      uvx --generate-shell-completion "$shell" ;;
        bat)      bat --completion "$shell" ;;
        delta)    delta --generate-completion "$shell" ;;
        fd)       fd --gen-completions "$shell" ;;
        just)     just --completions "$shell" ;;
        rg)       rg --generate "complete-$shell" ;;
        task)     task --completion "$shell" ;;
        zellij)   zellij setup --generate-completion "$shell" ;;
        zizmor)   zizmor --completions "$shell" ;;
        *)        echo "no generator defined for $tool" >&2; return 1 ;;
    esac
}

shell="${1:-$(basename "${SHELL:-}")}"
case "$shell" in
    zsh)  dir="${HOME}/.zsh/completions";                                  prefix="_"; suffix="" ;;
    bash) dir="${XDG_DATA_HOME:-${HOME}/.local/share}/bash-completion/completions"; prefix="";  suffix="" ;;
    fish) dir="${XDG_CONFIG_HOME:-${HOME}/.config}/fish/completions";      prefix="";  suffix=".fish" ;;
    *)    _err "Unsupported shell: '${shell}' (expected zsh, bash or fish)"; exit 2 ;;
esac
dir="${COMPLETIONS_DIR:-$dir}"
mkdir -p "$dir"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

_info "Installing ${shell} completions to ${dir}"

installed=0 skipped=0 failed=0
for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        _skip "${tool}: not found, skipping"
        skipped=$((skipped + 1))
        continue
    fi
    if [[ "$tool" == cargo && "$shell" == fish ]]; then
        _skip "cargo: rustup has no fish completions (fish ships its own), skipping"
        skipped=$((skipped + 1))
        continue
    fi

    if generate "$tool" "$shell" >"${tmp}/out" 2>"${tmp}/err" </dev/null && [[ -s "${tmp}/out" ]]; then
        chmod 644 "${tmp}/out"
        # mv replaces the path itself, so stale symlinks are never written through.
        mv -f "${tmp}/out" "${dir}/${prefix}${tool}${suffix}"
        _ok "$tool"
        installed=$((installed + 1))
    else
        _err "${tool}: generator failed: $(head -n 1 "${tmp}/err")"
        failed=$((failed + 1))
    fi
done

echo ""
_info "${installed} installed, ${skipped} skipped, ${failed} failed"

case "$shell" in
    zsh)  _info "Reload with: rm -f ~/.zcompdump* && exec zsh" ;;
    bash) _info "Loaded on demand; requires the bash-completion package" ;;
esac

[[ "$failed" -eq 0 ]]
