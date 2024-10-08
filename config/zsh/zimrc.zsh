zmodule sindresorhus/pure --source async.zsh --source pure.zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-completions --fpath src
zmodule completion

if (( ${+commands[fzf]} )); then
    zmodule fzf
fi

ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
zmodule jeffreytse/zsh-vi-mode

autoload -U colors && colors
zmodule ohmyzsh/ohmyzsh --root plugins/colored-man-pages
