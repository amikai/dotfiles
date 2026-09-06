# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# set some homebrew env variable and set path {{{
eval $(/opt/homebrew/bin/brew shellenv)
# }}}

# general setting {{{
#set the PERMISSIONS for newly-created files
umask 077

# cacert
export SSL_CERT_FILE=/etc/ssl/cert.pem

export EDITOR="nvim"
export VISUAL="nvim"

# Globbing, not completion: `*.txt` also matches Foo.TXT. CASE_GLOB is zsh's
# default; this was on under zim, so it is kept to preserve that behaviour.
setopt NO_CASE_GLOB

# use vim keybinding
bindkey -v

autoload edit-command-line
zle -N edit-command-line
bindkey -M viins '^x^e' edit-command-line
bindkey -M vicmd "X" edit-command-line

# }}}

# history setting {{{
export HISTFILE=$XDG_CACHE_HOME/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
# }}}

# plugins: sheldon {{{
# plugins.toml is a manifest -- parsed, never sourced. Shell code lives here.
export SHELDON_CONFIG_DIR="${XDG_CONFIG_HOME}/sheldon"
export SHELDON_DATA_DIR="${XDG_DATA_HOME}/sheldon"

# colored-man-pages reads $fg_bold/$bg at source time.
autoload -Uz colors && colors

# zsh-vi-mode reads this at source time, so it must precede the eval.
ZVM_VI_ESCAPE_BINDKEY=jk

if (( ${+commands[sheldon]} )); then
  eval "$(sheldon source)"
fi
# }}}

# fzf {{{
if (( ${+commands[fzf]} )); then
  source <(fzf --zsh)

  if (( ${+commands[fd]} )); then
    export FZF_DEFAULT_COMMAND="command fd -H --no-ignore-vcs -E .git -td -tf"
    export FZF_ALT_C_COMMAND="command fd -H --no-ignore-vcs -E .git -td"
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
    _fzf_compgen_path() { command fd -H --no-ignore-vcs -E .git -td -tf . "${1}" }
    _fzf_compgen_dir()  { command fd -H --no-ignore-vcs -E .git -td . "${1}" }
  fi

  if (( ${+commands[eza]} )); then
    export FZF_ALT_C_OPTS="--bind ctrl-/:toggle-preview --preview 'eza --group-directories-first --color=always -1F {}' ${FZF_ALT_C_OPTS}"
  fi

  # zvm_init runs at the first prompt, after this file, and rebinds viins ^R.
  # Its own hook is the only placement that survives.
  zvm_after_init() {
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M vicmd '/'  fzf-history-widget
    bindkey -M emacs '^R' fzf-history-widget
  }
fi
# }}}

declare -A BREW_PREFIX_PATH

# set c compiler {{{
BREW_PREFIX_PATH[llvm]="${HOMEBREW_PREFIX}/opt/llvm"
export CC="${BREW_PREFIX_PATH[llvm]}/bin/clang"
export CXX="${BREW_PREFIX_PATH[llvm]}/bin/clang++"
# }}}

# some basic utility {{{
BREW_PREFIX_PATH[coreutils]="${HOMEBREW_PREFIX}/opt/coreutils"
export PATH="${BREW_PREFIX_PATH[coreutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[findutils]="${HOMEBREW_PREFIX}/opt/findutils"
export PATH="${BREW_PREFIX_PATH[findutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[grep]="${HOMEBREW_PREFIX}/opt/grep"
export PATH="${BREW_PREFIX_PATH[grep]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[sed]="${HOMEBREW_PREFIX}/opt/gnu-sed"
export PATH="${BREW_PREFIX_PATH[sed]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[awk]="${HOMEBREW_PREFIX}/opt/gawk"
export PATH="${BREW_PREFIX_PATH[awk]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[tar]="${HOMEBREW_PREFIX}/opt/gnu-tar"
export PATH="${BREW_PREFIX_PATH[tar]}/libexec/gnubin:$PATH"

# Add to $PATH is not work, because time is built-in command
BREW_PREFIX_PATH[time]="${HOMEBREW_PREFIX}/opt/gnu-time/libexec/gnubin"

BREW_PREFIX_PATH[curl]="${HOMEBREW_PREFIX}/opt/curl"
export PATH="${BREW_PREFIX_PATH[curl]}/bin:$PATH"
# }}}

# zip tools {{{
BREW_PREFIX_PATH[zip]="${HOMEBREW_PREFIX}/opt/zip"
export PATH="${BREW_PREFIX_PATH[zip]}/bin:$PATH"

BREW_PREFIX_PATH[unzip]="${HOMEBREW_PREFIX}/opt/unzip"
export PATH="${BREW_PREFIX_PATH[unzip]}/bin:$PATH"

# }}}

# rust {{{
export PATH="$HOME/.cargo/bin:$PATH"
# }}}

# golang {{{
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# }}}

# some binary {{{
export PATH="$HOME/bin:$PATH"
# }}}

export CODEX_HOME="${XDG_CONFIG_HOME}/codex"
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
export ENABLE_LSP_TOOL=true # for claude

ls() {
    if command -v eza &> /dev/null; then
        command eza "$@"
    else
        command ls "$@"
    fi
}

xtime() {
    if [ -f "$BREW_PREFIX_PATH[time]/time" ]; then
        command "${HOMEBREW_PREFIX}/opt/gnu-time/libexec/gnubin/time" "$@"
    elif [ -f "/usr/bin/time" ]; then
        command "/usr/bin/time" "$@"
    else
        time "$@"
    fi
}

x-clean-branches() {
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    if [[ -z $default_branch ]]; then
        if git show-ref --verify --quiet refs/heads/master; then
            default_branch="master"
        elif git show-ref --verify --quiet refs/heads/main; then
            default_branch="main"
        else
            echo "\e[31mError: Could not determine default branch (master/main)\e[0m"
            return 1
        fi
    fi

    local has_gh=false
    command -v gh &>/dev/null && gh auth status &>/dev/null && has_gh=true

    echo "\e[33m==> Cleaning branches merged into '$default_branch'...\e[0m"

    local -a branches=("${(@f)$(git branch --format='%(refname:short)' | grep -v "^${default_branch}$")}")
    if [[ ${#branches} -eq 0 || -z ${branches[1]} ]]; then
        echo "\e[32mNo branches to clean up. Repository is already clean!\e[0m"
        return 0
    fi

    local deleted_count=0
    local branch msg pr_url pr_number repo_url

    for branch in $branches; do
        [[ -z $branch ]] && continue

        msg="" pr_url=""

        # Check 1: merged into default branch locally
        if git branch --merged $default_branch --format='%(refname:short)' | grep -q "^${branch}$"; then
            msg="merged into $default_branch"
        # Check 2: PR merged on GitHub
        elif $has_gh; then
            pr_number=$(gh pr list --head $branch --state merged --json number --jq '.[0].number' 2>/dev/null)
            if [[ -n $pr_number ]]; then
                repo_url=$(gh repo view --json url --jq '.url' 2>/dev/null)
                pr_url="${repo_url}/pull/${pr_number}"
                msg="#${pr_number}"
            fi
        fi

        [[ -z $msg ]] && continue

        # Check if branch is checked out in a worktree
        local worktree_path
        worktree_path=$(git for-each-ref --format='%(worktreepath)' "refs/heads/$branch")

        # Print status with optional hyperlink
        if [[ -n $pr_url ]]; then
            printf "\e[32m [OK] Removing branch:\e[0m %s \e[34m(merged in \e]8;;%s\e\\%s\e]8;;\e\\)\e[0m\n" \
                "$branch" "$pr_url" "$msg"
        else
            echo "\e[32m [OK] Removing branch:\e[0m $branch \e[34m($msg)\e[0m"
        fi

        # Remove worktree first if branch is checked out there
        if [[ -n $worktree_path ]]; then
            echo "  \e[33m-> Removing worktree at: $worktree_path\e[0m"
            if ! git worktree remove --force "$worktree_path" &>/dev/null; then
                echo "\e[31m [FAIL] Failed to remove worktree: $worktree_path\e[0m"
                continue
            fi
        fi

        if git branch -D $branch &>/dev/null; then
            ((deleted_count++))
        else
            echo "\e[31m [FAIL] Failed to delete branch: $branch\e[0m"
        fi
    done

    echo "Removed $deleted_count merged branch(es)."
}

x-aws-login() {
  local profile="${1:-dev}"
  aws sso login --profile "$profile" && \
  export AWS_PROFILE="$profile" && \
  export AWS_REGION=$(aws configure get region --profile "$profile")
  echo "Set AWS_PROFILE=$AWS_PROFILE AWS_REGION=$AWS_REGION"
}

export PATH="${HOME}/bin:$PATH"

# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :


# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
# Rerunning the installer re-adds `compinit -C` here; delete it again.
# <<< grok installer <<<

# completion {{{
# Must stay at the very bottom: compinit has to see every fpath entry added
# above, and it must be called exactly once.
() {
  local zdumpfile=${XDG_CACHE_HOME}/zsh/zcompdump
  [[ -d ${zdumpfile:h} ]] || command mkdir -p ${zdumpfile:h}
  autoload -Uz compinit
  # Full rebuild if the dump is missing or older than a day, cheap load otherwise.
  if [[ -n ${zdumpfile}(#qN.md-1) ]]; then
    compinit -C -d ${zdumpfile}
  else
    compinit -d ${zdumpfile}
    [[ ! ${zdumpfile}.zwc -nt ${zdumpfile} ]] && zcompile ${zdumpfile}
  fi
}

setopt ALWAYS_TO_END      # move cursor to end of word on full completion
setopt COMPLETE_IN_WORD   # complete from both ends of the cursor
setopt NO_LIST_BEEP

zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' single-ignored show

# Case-insensitive, then partial-word, then substring.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' '+r:|[._-]=* r:|=*' '+l:|=*'

zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections'  format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages'     format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings'     format '%F{red}-- no matches found --%f'

zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'

if (( ${+LS_COLORS} )); then
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  zstyle ':completion:*:default' list-colors ${(s.:.):-di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43}
fi
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
# }}}


# Added by Antigravity CLI installer
export PATH="/Users/amikai/.local/bin:$PATH"

# Activate after PATH customizations so mise selects the runtime versions.
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi
