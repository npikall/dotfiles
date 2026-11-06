#!/usr/bin/env bash
# Print information about packages and bundles.
#
# Usage: info.sh summary    one-line overview (shown above `just --list`)
#        info.sh list       every package and where it gets linked
#        info.sh bundles    every bundle and its packages

set -eo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

case $1 in
    summary)
        printf '%sPackages:%s %s%s%s\n' "$BOLD" "$RESET" "$BLUE" "$(packages | xargs)" "$RESET"
        printf '%sBundles:%s  %s%s%s\n\n' "$BOLD" "$RESET" "$BLUE" "$(bundles | xargs)" "$RESET"
        ;;
    list)
        for pkg in $(packages); do
            printf '  %s%s%-10s%s → %s\n' "$BLUE" "$BOLD" "$pkg" "$RESET" "$(pretty "$(target_of "$pkg")")"
        done
        ;;
    bundles)
        for bundle in $(bundles); do
            printf '  %s%-7s%s %s\n' "$BOLD" "$bundle:" "$RESET" "$(bundle_of "$bundle" | xargs)"
        done
        ;;
    *)
        die "usage: info.sh summary|list|bundles"
        ;;
esac
