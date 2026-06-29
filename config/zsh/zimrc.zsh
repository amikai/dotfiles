# Prompt {{{
zmodule sindresorhus/pure --source async.zsh --source pure.zsh
# }}}

# Editor / input {{{
# Applies correct bindkeys for input events
zmodule input

# Provides a convenient way to load ssh-agent. This enables one-time login and
# caching of ssh credentials per session.
zstyle ':zim:ssh' ids 'id_ed25519'
zmodule ssh

# vi mode. ZVM rebinds keys on init, so any plugin that binds keys (fzf,
# autosuggestions, syntax-highlighting) MUST be loaded after it.
export ZVM_VI_ESCAPE_BINDKEY=jk
zmodule jeffreytse/zsh-vi-mode
if (( ${+commands[fzf]} )); then
    zmodule fzf
fi

# ZVM resets keybindings after its own init; rebind fzf widgets here.
function zvm_after_init() {
    zvm_bindkey viins '^R' fzf-history-widget
    zvm_bindkey vicmd '/' fzf-history-widget
    zvm_bindkey emacs '^R' fzf-history-widget
}
# }}}

# Misc {{{
zmodule ohmyzsh/ohmyzsh --root plugins/colored-man-pages
autoload -U colors && colors
# }}}

# Completion {{{
# zsh-completions only adds to fpath, so it must come BEFORE the completion
# module (which runs compinit).
zmodule zsh-users/zsh-completions --fpath src
zmodule completion
# }}}

# MUST be loaded last {{{
# These wrap ZLE widgets, so they have to run after compinit and after every
# other widget-defining plugin above. syntax-highlighting before
# autosuggestions, per zim's default order.
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
# }}}

# -- vim: set foldmethod=marker :
