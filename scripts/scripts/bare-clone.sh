#!/usr/bin/env bash

set -e

function gbc() {
    local url="$1"

    if [ "$url" = "-h" ] || [ "$url" = "--help" ]; then
        cat <<'EOF'
Usage: gbc <git-url>

Clone a repo as a bare repo set up for git worktrees.

Example:
  gbc git@github.com:user/repo.git

Result:
  repo/.git      bare repository
  repo/<branch>  worktree checked out to the default branch
EOF
        return 0
    fi

    if [ -z "$url" ]; then
        echo "Usage: gbc <git-url>  (gbc --help for details)" >&2
        return 1
    fi

    local reponame
    reponame=$(basename "${url%/}")
    reponame="${reponame%.git}"

    if [ -e "$reponame" ]; then
        echo "Error: '${reponame}' already exists." >&2
        return 1
    fi

    git clone --bare "$url" "${reponame}/.git"

    local branch
    branch=$(git --git-dir="${reponame}/.git" symbolic-ref --short HEAD)

    git --git-dir="${reponame}/.git" worktree add "${reponame}/${branch}" "${branch}"

    echo "Ready: ${reponame}/${branch}"
}

gbc "$@"
