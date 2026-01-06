zmodule sindresorhus/pure --source async.zsh --source pure.zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-completions --fpath src

# Applies correct bindkeys for input events
zmodule input

# Provides a convenient way to load ssh-agent. This enables one-time login and
# caching of ssh credentials per session.
zstyle ':zim:ssh' ids 'id_ed25519'
zmodule ssh

zmodule lukechilds/zsh-nvm

export ZVM_VI_ESCAPE_BINDKEY=jk
zmodule jeffreytse/zsh-vi-mode
if (( ${+commands[fzf]} )); then
    zmodule fzf
fi

function zvm_after_init() {
    zvm_bindkey viins '^R' fzf-history-widget
    zvm_bindkey vicmd '/' fzf-history-widget
    zvm_bindkey emacs '^R' fzf-history-widget
}


zmodule ohmyzsh/ohmyzsh --root plugins/colored-man-pages
autoload -U colors && colors

zmodule completion
