#!/usr/bin/bash

function templ() {
    local choice=$(gum choose "PyBootstrap" "TUCookbook" "None" --header "Choose a template.")

    case "$choice" in
    "PyBootstrap")
        repo="gh:npikall/py-bootstrap"
        ;;
    "TUCookbook")
        repo="git+https://gitlab.tuwien.ac.at/cookbooks/templates/tu-cookbook-python"
        ;;
    "None")
        return
        ;;
    *)
        echo "invalid choice"
        return 1
        ;;
    esac

    local target=$(gum input --header "Set the target directory")

    copier copy --trust "$repo" $target
}

templ
