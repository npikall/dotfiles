#!/usr/bin/env bash

function gc() {
    local server user repo

    # Determine server based on first argument
    if [ "$1" = "gl" ] || [ "$1" = "gitlab" ]; then
        server="git@gitlab.com"
        shift # Remove server from args
    elif [[ "$1" == *"@"* ]]; then
        server="$1" # It's already a full URL
        shift
    else
        server="git@github.com" # Default to GitHub
    fi

    # Get user and repo from remaining arguments
    if [ $# -ge 2 ]; then
        user=$1
        repo=$2
    elif [ $# -eq 1 ]; then
        user=$1
        repo=$(gum input --prompt "Repository name: " --placeholder "repo-name")
    else
        # Interactive prompts
        if command -v gum &>/dev/null; then
            user=$(gum input --prompt "GitHub/GitLab username: " --placeholder "username")
            repo=$(gum input --prompt "Repository name: " --placeholder "repo-name")
        else
            read -p "GitHub/GitLab username: " user
            read -p "Repository name: " repo
        fi
    fi

    # Remove .git from repo name if present
    repo="${repo%.git}"

    echo "Cloning ${server}:${user}/${repo}.git -> ${repo}/.git"
    git clone --bare "${server}:${user}/${repo}.git" "${repo}/.git"
}

gc "$@"
