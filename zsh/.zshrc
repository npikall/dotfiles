plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

alias ..='echo "cd .."; cd ..'
alias c="clear"
alias vim="nvim"
alias vi='nvim'
alias ve='echo "source .venv/bin/activate"; source .venv/bin/activate'
alias de='echo "deactivate"; deactivate'
alias dev='zellij --layout $HOME/.config/zellij/layouts/server.kdl'
alias pomo='$HOME/scripts/pomo-mac.sh'
alias gi='lazygit'
alias ll='ls -lha'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fzf --zsh)"

export GPG_TTY=$(tty)


export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin
export EDITOR=nvim

export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_se=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

. "$HOME/.local/bin/env"

_fix_cursor() { echo -ne '\e[2 q'; }
precmd_functions+=(_fix_cursor)
zle-line-init() { echo -ne '\e[2 q'; }
zle -N zle-line-init
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
