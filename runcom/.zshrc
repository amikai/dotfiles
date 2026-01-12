# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# set some homebrew env variable and set path {{{
eval $(/opt/homebrew/bin/brew shellenv)
# }}}

# general setting {{{
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077

# cacert
export SSL_CERT_FILE=/etc/ssl/cert.pem

export EDITOR="nvim"
export VISUAL="nvim"

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

# zim setting {{{
zstyle ':zim:zmodule' use 'degit'
ZIM_HOME="${XDG_CACHE_HOME}/zim"
ZIM_CONFIG_FILE="${XDG_CONFIG_HOME}/zsh/zimrc.zsh"
ZVM_INIT_MODE=sourcing

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh
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
BREW_PREFIX_PATH[golang]="${HOMEBREW_PREFIX}/opt/go"
export GOROOT="${BREW_PREFIX_PATH[golang]}/libexec"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# }}}

# some binary {{{
export PATH="$HOME/bin:$PATH"
# }}}


export CODEX_HOME="${XDG_CONFIG_HOME}/codex"

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
    # Determine the default branch (master or main)
    local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    if [[ -z $default_branch ]]; then
        if git show-ref --verify --quiet refs/heads/master; then
            default_branch="master"
        elif git show-ref --verify --quiet refs/heads/main; then
            default_branch="main"
        else
            print -P "%F{red}Error: Could not determine default branch (master/main)%f"
            return 1
        fi
    fi

    # Check if gh CLI is available
    local has_gh=false
    if command -v gh &>/dev/null && gh auth status &>/dev/null; then
        has_gh=true
    fi

    print -P "%F{yellow}==> Cleaning branches merged into '$default_branch'...%f"

    local -a all_branches
    all_branches=("${(@f)$(git branch --format='%(refname:short)' | grep -v "^${default_branch}$")}")

    if [[ ${#all_branches} -eq 0 || (${#all_branches} -eq 1 && -z ${all_branches[1]}) ]]; then
        print -P "%F{green}No branches to clean up. Repository is already clean!%f"
        exit 0
    fi

    local deleted_count=0

    for branch in $all_branches; do
        [[ -z $branch ]] && continue
        
        local is_merged=false
        local merge_reason=""

        # Check 1: Is branch merged into default branch locally?
        if git branch --merged $default_branch --format='%(refname:short)' | grep -q "^${branch}$"; then
            is_merged=true
            merge_reason="merged into $default_branch"
        fi

        # Check 2: Is PR merged on GitHub?
        if [[ $is_merged == false && $has_gh == true ]]; then
            local pr_number=$(gh pr list --head $branch --state merged --json number --jq '.[0].number' 2>/dev/null)
            if [[ -n $pr_number ]]; then
                is_merged=true
                local repo_url=$(gh repo view --json url --jq '.url' 2>/dev/null)
                local pr_url="${repo_url}/pull/${pr_number}"
                local pr_link=$'\e]8;;'"${pr_url}"$'\e\\'"#${pr_number}"$'\e]8;;\e\\'
                merge_reason="merged in ${pr_link}"
            fi
        fi

        # Delete if merged
        if [[ $is_merged == true ]]; then
            print -P "%F{green} [OK] Removing branch:%f $branch %F{blue}($merge_reason)%f"
            
            if git branch -D $branch &>/dev/null; then
                ((deleted_count++))
            else
                print -P "%F{red} [FAIL] Failed to delete branch: $branch, ${merge_reason}%f"
            fi
        fi
    done
    print -P "Removed $deleted_count merged branch(es)."
}


# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :

