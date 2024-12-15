zmodule sindresorhus/pure --source async.zsh --source pure.zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

ZVM_VI_ESCAPE_BINDKEY=jk
zmodule jeffreytse/zsh-vi-mode
if (( ${+commands[fzf]} )); then
    zmodule fzf
fi

export NVM_COMPLETION=true
zmodule lukechilds/zsh-nvm

function zvm_after_init() {
    zvm_bindkey viins '^R' fzf-history-widget
    zvm_bindkey vicmd '/' fzf-history-widget
    zvm_bindkey emacs '^R' fzf-history-widget
}


zmodule ohmyzsh/ohmyzsh --root plugins/colored-man-pages
autoload -U colors && colors
