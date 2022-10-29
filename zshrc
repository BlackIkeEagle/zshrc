#######################################
# BlackEagle's .zshrc                 #
#######################################

#=====================================#
# start tmux session when using ssh   #
#=====================================#

if which tmux > /dev/null 2>&1 \
    && [[ "$SSH_CLIENT" != "" ]] \
    && [[ -z ${TMUX} ]] \
    && [[ "$(id -u)" != "0" ]]
then
    if tmux has-session; then
        if tmux has-session -t default; then
            exec tmux a -t default
        else
            exec tmux a
        fi
    else
        exec tmux new -s default
    fi
fi

#=====================================#
# force TERM if truecolor             #
#=====================================#

if [[ ! -z $COLORTERM ]] && [[ "$COLORTERM" == "truecolor" ]]; then
    export TERM=xterm-256color
fi

#=====================================#
# Add extras to path if existing      #
#=====================================#

if [[ -d $HOME/go/bin && ":$PATH:" != *:"$HOME/go/bin":* ]]; then
    PATH=$HOME/go/bin:$PATH
fi

if [[ -d $HOME/.bin && ":$PATH:" != *:"$HOME/.bin":* ]]; then
    PATH=$HOME/.bin:$PATH
fi

if [[ -d $HOME/.local/bin && ":$PATH:" != *:"$HOME/.local/bin":* ]]; then
    PATH=$HOME/.local/bin:$PATH
fi

#=====================================#
# Keybindings                         #
#=====================================#

# vi mode
#bindkey -v
# emacs mode
bindkey -e

# context aware history search
bindkey "^[[5~" history-search-backward
bindkey "^[[6~" history-search-forward

#=====================================#
# History settings                    #
#=====================================#

export HISTFILE=~/.zsh_history
export HISTSIZE=409600
export SAVEHIST=819200
# make sure we append history to the history file
setopt appendhistory
# share history among different running shells
setopt share_history
# don't remember duplicates
setopt histignorealldups

#=====================================#
# zsh settings                        #
#=====================================#

# avoid beeping
setopt nobeep
# cd when only a path is given
setopt autocd

#=====================================#
# Load zsh modules                    #
#=====================================#

autoload -Uz compinit
compinit

# when new binaries are added by default they are not
# completed, when we dont trust the hash they are
zstyle ":completion:*:commands" rehash 1

# completion options
zstyle -e ':completion:*:(ssh|scp):*' hosts 'reply=(
    ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) \
        /dev/null)"}%%[# ]*}//,/ }
    ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
        ${=${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# case-sensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# get a complete list of pids for the current user
if [[ "$(id -u)" != "0" ]]; then
    zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
else
    zstyle ':completion:*:*:*:*:processes' command "ps -e -o pid,user,comm -w -w"
fi

# show menu for completion options
zstyle ':completion:*' menu select

#=====================================#
# Load config                         #
#=====================================#

if [[ -e $HOME/.zshrc.config ]]; then
    source $HOME/.zshrc.config
elif [[ -e /etc/zsh/zshrc.config ]]; then
    source /etc/zsh/zshrc.config
fi

#=====================================#
# Default prompt colors               #
#=====================================#

# defaults
[[ -z $PSCOL ]] && PSCOL='%{%F{yellow}%}'
[[ -z $USRCOL ]] && USRCOL='%{%F{yellow}%}'
[[ -z $HSTCOL ]] && HSTCOL='%{%F{grey}%}'
# default flags
[[ -z $SCMENABLED ]] && SCMENABLED=1
[[ -z $SCMDIRTY ]] && SCMDIRTY=1

if [[ "$(id -u)" = "0" ]]; then
    PSCOL='%{%F{red}%}';
    USRCOL='%{%F{red}%}';
fi

#=====================================#
# vcs configuration                   #
#=====================================#

if [[ 1 == $SCMENABLED ]]; then
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git hg svn
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' check-for-staged-changes true
    zstyle ':vcs_info:*' stagedstr " +"
    zstyle ':vcs_info:*' unstagedstr " *"
    zstyle ':vcs_info:*' formats "${PSCOL}─(%{%F{yellow}%}%s${PSCOL})─(%{%F{cyan}%}%b%F{red}%}%u%F{green}%}%c${PSCOL})"
    precmd() {
        vcs_info
    }
fi

#=====================================#
# EDITOR is vim ofcourse              #
#=====================================#

export EDITOR=vim;

#=====================================#
# ALIASES                             #
#=====================================#

if ls --version > /dev/null 2>&1; then
    alias ls='ls --color=auto'; #gnu
else
    alias ls='ls -G'; #osx
fi
alias grep='grep --color';
alias cd..='cd ..';

if [[ -f $HOME/.aliases ]]; then
    source $HOME/.aliases
fi

#=====================================#
# FUNCTIONS                           #
#=====================================#

function fldcol {
    local width=$(ttywidth)
    local maxfolderlength=$(( width - 70 ))
    if [[ $width -le 90 ]]; then
        maxfolderlength=$((width - 35))
    fi
    if [[ $maxfolderlength -le 10 ]]; then
        maxfolderlength=10
    fi
    local folder="$(echo "${PWD/#$HOME/~}")"
    local folderlength=${#folder}
    if [[ $folderlength -gt $maxfolderlength ]]; then
        maxfolderlength=$(( maxfolderlength - 3))
        folder="...$(echo -n "$folder" | tail -c $maxfolderlength)"
    fi

    if [[ $PWD =~ ^\/etc ]]; then
        FLDCOL="%{%F{red}%}%B%U${folder}%u%b"
    elif [[ $PWD =~ ^\/var/log ]]; then
        FLDCOL="%{%F{red}%}%B%U${folder}%u%b"
    elif [[ $PWD =~ \/devel ]] || [[ $PWD =~ \/code ]]; then
        FLDCOL="%{%F{grey}%}%B%U${folder}%u%b"
    else
        FLDCOL="%{%F{cyan}%}%B${folder}%b"
    fi
    echo -ne ${FLDCOL}
}

function ttywidth {
    stty size | read rows columns
    echo -ne $columns
}

function userinfo {
    local width=$(ttywidth)
    local usrinfo=""
    if [[ $width -gt 90 ]]; then
        usrinfo+="─┤${SESSCOL}${PSCOL}├─┤${USRCOL}%B%n%b${PSCOL} @ ${HSTCOL}%B%M%b${PSCOL}├"
    fi
    echo -ne $usrinfo
}

function extendedps {
    if [[ -z ${TMUX} ]]; then
        if [[ 1 == $SCMENABLED ]]; then
            echo -ne "$(userinfo)─┤$(fldcol)${PSCOL}├${vcs_info_msg_0_}"
        else
            echo -ne "$(userinfo)─┤$(fldcol)${PSCOL}├"
        fi
    fi
}

#=====================================#
# Session colors tty/ssh/screen       #
#=====================================#

if [[ "$SSH_CLIENT" != "" ]]; then
    # SSH
    SESSCOL='%{%F{red}%}%B%*%b'
elif [[ "$STY" != "" ]]; then
    # screen
    SESSCOL='%{%F{cyan}%}%B%*%b'
elif [[ ! -z $TMUX ]]; then
    # tmux
    SESSCOL='%{%F{cyan}%}%B%*%b'
else
    SESSCOL='%*'
fi

#=====================================#
# Configure prompt                    #
#=====================================#

setopt prompt_subst
PROMPT='${PSCOL}┌─┤%(?,%F{green}%}%B●%b,%F{red}%}%B●%b)${PSCOL}├$(extendedps)─╼
└╼ %{%F{reset}%}'
