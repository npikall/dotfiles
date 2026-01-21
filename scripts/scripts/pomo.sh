#!/usr/bin/bash

# Pomodoro timer script for Linux Mint
# Requires: timer (https://github.com/caarlos0/timer), gum (https://github.com/charmbracelet/gum), notify-send

function pom() {
    local split="${POMO_SPLIT:-}"

    if [ -z "$split" ]; then
        split=$(gum choose "25/5" "50/10" "all done" --header "Choose a pomodoro split.")
    fi

    case "$split" in
    "25/5")
        work="25m"
        break="5m"
        ;;
    "50/10")
        work="50m"
        break="10m"
        ;;
    "all done")
        return
        ;;
    *)
        echo "Invalid choice"
        return 1
        ;;
    esac

    timer -n "work" "$work" &&
        notify-send -u normal "Pomodoro" "Work Timer is up! Take a Break 😊" &&
        gum confirm "Ready for a break?" &&
        timer -n "break" "$break" &&
        notify-send -u normal "Pomodoro" "Break is over! Get back to work 😬"
}

# Execute the function if script is run directly
if [ "$0" == "$BASH_SOURCE" ]; then
    pom
fi
