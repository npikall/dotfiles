# Enable the subsequent settings only in interactive sessions
case $- in
*i*) ;;
*) return ;;
esac
eval "$(starship init bash)"

export OSH='/home/npikall/.oh-my-bash'
export TYPST_FONT_PATHS=/mnt/c/Users/npikall/AppData/Local/Microsoft/Windows/Fonts/

OSH_THEME="font"
OMB_USE_SUDO=true

completions=(
    git
    composer
    ssh
)

aliases=(
    general
)

plugins=(
    git
    bashmarks
)

source "$OSH"/oh-my-bash.sh

alias ls="ls --color -x"
alias vim="nvim"
alias vi="nvim"
alias nvi="nvim"
eval "$(starship init bash)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/npikall/miniconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/npikall/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/npikall/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/npikall/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

. "/home/npikall/.deno/env"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
