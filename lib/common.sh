# Shared helpers, sourced by the other scripts in lib/.
# Written for bash 3.2 (macOS default): no associative arrays.

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CONF="$DOTFILES/packages.conf"

# Top-level directories that are not stow packages.
NOT_PACKAGES="lib"

case "$(uname -s)" in
    Darwin) OS=macos CONFIG_DIR="$HOME/Library/Application Support" SHELL_PKG=zsh ;;
    *)      OS=linux CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}" SHELL_PKG=bash ;;
esac

if [[ -t 1 ]]; then
    BOLD=$'\033[1m' DIM=$'\033[2m' RED=$'\033[31m' GREEN=$'\033[32m'
    YELLOW=$'\033[33m' BLUE=$'\033[34m' RESET=$'\033[0m'
fi

die() { printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }

# Shorten $HOME to ~ for display.
pretty() { printf '%s' "${1/#$HOME/~}"; }

# packages.conf without comments and blank lines.
conf() { sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$CONF"; }

# Replace placeholders like {config} with real values.
expand() {
    local s=$1
    s=${s//\{config\}/$CONFIG_DIR}
    s=${s//\{shell\}/$SHELL_PKG}
    [[ $s == "~"* ]] && s="$HOME${s#\~}"
    printf '%s' "$s"
}

# Where a package gets linked: ~ unless packages.conf says otherwise.
# Prints nothing if the package is limited to another OS.
target_of() {
    local kind name dir os
    while read -r kind name dir os; do
        [[ $kind == target && $name == "$1" ]] || continue
        [[ -z $os || $os == "$OS" ]] && expand "$dir"
        return 0
    done < <(conf)
    printf '%s' "$HOME"
}

# All packages available on this OS, one per line.
packages() {
    local dir name
    for dir in "$DOTFILES"/*/; do
        name=$(basename "$dir")
        [[ " $NOT_PACKAGES " == *" $name "* ]] && continue
        [[ -n $(target_of "$name") ]] && printf '%s\n' "$name"
    done
}

# All bundle names, one per line.
bundles() { conf | awk '$1 == "bundle" { print $2 }'; }

# Packages in a bundle; bundles inside bundles are expanded.
bundle_of() {
    local kind name members m
    while read -r kind name members; do
        [[ $kind == bundle && $name == "$1" ]] || continue
        for m in $(expand "$members"); do
            if bundles | grep -x "$m" >/dev/null; then bundle_of "$m"; else printf '%s\n' "$m"; fi
        done
        return 0
    done < <(conf)
}

assert_package() {
    packages | grep -x "$1" >/dev/null ||
        die "unknown package '$1'. Available: $(packages | xargs)"
}

assert_bundle() {
    bundles | grep -x "$1" >/dev/null ||
        die "unknown bundle '$1'. Available: $(bundles | xargs)"
}
