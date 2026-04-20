#!/usr/bin/env bash

function gc() {
    local user repo

    if [ $# -eq 2 ]; then
        # Use provided arguments
        user=$1
        repo=$2
    else
        # Prompt for input
        if command -v gum &>/dev/null; then
            user=$(gum input --prompt "GitHub username: " --placeholder "username")
            repo=$(gum input --prompt "Repository name: " --placeholder "repo-name")
        else
            [ -z "$user" ] && read -p "GitHub username: " user
            [ -z "$repo" ] && read -p "Repository name: " repo
        fi
    fi

    # Validate inputs
    if [ -z "$user" ] || [ -z "$repo" ]; then
        echo "Error: Both username and repository are required."
        return 1
    fi

    # Clone the repository as bare
    echo "Cloning ${user}/${repo}..."
    git clone --bare "git@github.com:${user}/${repo}.git" "${repo}/.git"
}

gc "$@"
