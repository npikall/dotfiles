#!/usr/bin/env bash
# Report which stow packages are installed, partially installed, not
# installed, and which stale (dangling) links into the repo are left behind.
#
# Usage: status.sh

set -eo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

dotfiles=$(realpath "$DOTFILES")
repo_name=$(basename "$dotfiles")

# Stow's default ignore list (subset that matters here).
ignored() {
    case "$(basename "$1")" in
        .git | .gitignore | README* | LICENSE* | COPYING | *~ | '#'*'#' | .'#'*) return 0 ;;
    esac
    return 1
}

installed="" partial="" missing="" scan_dirs=""

for pkg in $(packages); do
    target=$(target_of "$pkg")
    total=0 linked=0 conflicts=0

    while IFS= read -r -d '' src; do
        ignored "$src" && continue
        rel=${src#"$dotfiles/$pkg/"}
        dest="$target/$rel"
        total=$((total + 1))
        if [[ -e $dest && $(realpath "$dest") == "$(realpath "$src")" ]]; then
            linked=$((linked + 1))
        elif [[ -e $dest || -L $dest ]]; then
            conflicts=$((conflicts + 1))
        fi
    done < <(find "$dotfiles/$pkg" \( -type f -o -type l \) -print0)

    note=""
    ((conflicts > 0)) && note=" ${YELLOW}${conflicts} conflicting${RESET}"
    line=$(printf '%-10s %s' "$pkg" "$(pretty "$target")")

    if ((total > 0 && linked == total)); then
        installed+="  ${GREEN}✓${RESET} ${line}"$'\n'
    elif ((linked > 0)); then
        partial+="  ${YELLOW}◐${RESET} ${line} ${DIM}(${linked}/${total} linked)${RESET}${note}"$'\n'
    else
        missing+="  ${RED}✗${RESET} ${line}${note}"$'\n'
    fi

    # Directories where stale links of this package could live.
    scan_dirs+="$target"$'\n'
    while IFS= read -r -d '' dir; do
        scan_dirs+="$target/${dir#"$dotfiles/$pkg/"}"$'\n'
    done < <(find "$dotfiles/$pkg" -mindepth 1 -type d -print0)
done

# Stale = dangling symlink that points into the repo.
stale=""
while IFS= read -r dir; do
    [[ -d $dir ]] || continue
    # Skip dirs that resolve into the repo (inside a folded package link).
    [[ $(realpath "$dir") == "$dotfiles"/* ]] && continue
    while IFS= read -r -d '' link; do
        [[ -e $link ]] && continue
        dest=$(readlink "$link")
        [[ $dest == *"$repo_name/"* ]] || continue
        stale+="  ${RED}!${RESET} $(pretty "$link") ${DIM}→ $(pretty "$dotfiles")/${dest#*"$repo_name/"} (missing)${RESET}"$'\n'
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type l -print0)
done < <(printf '%s' "$scan_dirs" | sort -u)

section() {
    local title=$1 body=$2 empty=$3
    printf '%s%s%s\n' "$BOLD" "$title" "$RESET"
    if [[ -n $body ]]; then printf '%s' "$body"; else printf '  %s%s%s\n' "$DIM" "$empty" "$RESET"; fi
    printf '\n'
}

section "Installed" "$installed" "none"
[[ -n $partial ]] && section "Partially installed" "$partial" ""
section "Not installed" "$missing" "none"
section "Stale links" "$stale" "none"
printf '%sFix stale links: remove them, or re-stow the package with just stow <pkg>.%s\n' "$DIM" "$RESET"
