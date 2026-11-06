#!/usr/bin/env bash
# Link or unlink packages with GNU Stow and print what changed.
#
# Usage: stow.sh link|unlink <pkg>...
#        stow.sh link-bundle|unlink-bundle <bundle>

set -eo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Turn `stow -v` output into readable "+ target → source" lines.
report() {
    local target=$1 source=$2 changes=0 line file
    while IFS= read -r line; do
        case $line in
            "LINK: "*)
                file=${line#LINK: }
                file=${file%% => *}
                printf '  %s+%s %s/%s %s→ %s/%s%s\n' "$GREEN" "$RESET" "$target" "$file" "$DIM" "$source" "$file" "$RESET"
                ;;
            "UNLINK: "*)
                file=${line#UNLINK: }
                printf '  %s-%s %s/%s\n' "$RED" "$RESET" "$target" "$file"
                ;;
            "MV: "*)
                file=${line#MV: }
                file=${file%% -> *}
                printf '  %s~%s %s/%s %sadopted into repo%s\n' "$YELLOW" "$RESET" "$target" "$file" "$DIM" "$RESET"
                ;;
            "MKDIR: "* | "RMDIR: "*)
                continue
                ;;
            *)
                printf '%s\n' "$line"
                continue
                ;;
        esac
        changes=$((changes + 1))
    done
    ((changes > 0)) || printf '  %snothing to do%s\n' "$DIM" "$RESET"
}

link() {
    local pkg=$1 target
    target=$(target_of "$pkg")
    printf '%s%s%s → %s\n' "$BOLD" "$pkg" "$RESET" "$(pretty "$target")"
    mkdir -p "$target"
    stow -v --adopt -d "$DOTFILES" -t "$target" "$pkg" 2>&1 |
        report "$(pretty "$target")" "$(pretty "$DOTFILES")/$pkg"
}

unlink() {
    local pkg=$1 target
    target=$(target_of "$pkg")
    printf '%s%s%s ✗ %s\n' "$BOLD" "$pkg" "$RESET" "$(pretty "$target")"
    stow -v -D -d "$DOTFILES" -t "$target" "$pkg" 2>&1 |
        report "$(pretty "$target")" "$(pretty "$DOTFILES")/$pkg"
}

action=$1
shift || true

case $action in
    link | unlink)
        pkgs=("$@")
        ;;
    link-bundle | unlink-bundle)
        assert_bundle "$1"
        pkgs=($(bundle_of "$1"))
        action=${action%-bundle}
        ;;
    *)
        die "usage: stow.sh link|unlink <pkg>... | link-bundle|unlink-bundle <bundle>"
        ;;
esac

# Check everything first so a typo doesn't leave a half-done run.
for pkg in "${pkgs[@]}"; do assert_package "$pkg"; done
for pkg in "${pkgs[@]}"; do "$action" "$pkg"; done
