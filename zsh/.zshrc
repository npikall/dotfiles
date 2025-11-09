export TYPST_PACKAGE_PATH="~/Library/Application Support/typst/packages/local"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

alias c="clear"
alias vim="nvim"



function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(starship init zsh)"
