plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

alias c="clear"
alias vim="nvim"
alias ve="source .venv/bin/activate"
alias dev='zellij --layout $HOME/.config/zellij/layouts/server.kdl'
alias pomo='$HOME/scripts/pomo-mac.sh'


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

export GPG_TTY=$(tty)


export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin
export PATH=$PATH:$GOPATH/bin

. "$HOME/.local/bin/env"
