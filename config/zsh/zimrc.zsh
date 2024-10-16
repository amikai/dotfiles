zmodule sindresorhus/pure --source async.zsh --source pure.zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

if (( ${+commands[fzf]} )); then
    zmodule fzf
fi

ZVM_VI_ESCAPE_BINDKEY=jk
zmodule jeffreytse/zsh-vi-mode

function zvm_after_init() {
    zvm_bindkey viins '^R' fzf-history-widget
    zvm_bindkey vicmd '/' fzf-history-widget
    zvm_bindkey emacs '^R' fzf-history-widget
}


zmodule ohmyzsh/ohmyzsh --root plugins/colored-man-pages
autoload -U colors && colors
