plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

alias c="clear"
alias vim="nvim"
alias vi='nvim'
alias ve="source .venv/bin/activate"
alias dev='zellij --layout $HOME/.config/zellij/layouts/server.kdl'
alias pomo='$HOME/scripts/pomo-mac.sh'
alias gi='lazygit'


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

. "$HOME/.local/bin/env"

_fix_cursor() { echo -ne '\e[2 q'; }
precmd_functions+=(_fix_cursor)
zle-line-init() { echo -ne '\e[2 q'; }
zle -N zle-line-init
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
