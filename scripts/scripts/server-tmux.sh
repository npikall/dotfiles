#!/bin/bash

# Exit if tmux session already exists
tmux has-session -t dev 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Session already exists. Attaching..."
    tmux attach -t dev
    exit 0
fi

# Create a new detached session
tmux new-session -d -s dev -n "code"

# Set up code window with editor and terminal

# Create server window
tmux new-window -t dev:1 -n "server"

# Select the first window and attach
tmux select-window -t dev:0
tmux attach-session -t dev
