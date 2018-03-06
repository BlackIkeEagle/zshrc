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
# Add .bin if it exists               #
#=====================================#

if [[ -d $HOME/.bin && ":$PATH:" != *:"$HOME/.bin":* ]]; then
    PATH=$HOME/.bin:$PATH
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
export HISTSIZE=4096
export SAVEHIST=8192
# make sure we append history to the history file
setopt appendhistory
# share history among different running shells
#setopt share_history
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
[[ -z $HSTCOL ]] && HSTCOL='%{%F{white}%}'
# default flags
[[ -z $SCMENABLED ]] && SCMENABLED=1
[[ -z $SCMDIRTY ]] && SCMDIRTY=1

if [[ "$(id -u)" = "0" ]]; then
    PSCOL='%{%F{red}%}';
    USRCOL='%{%F{red}%}';
fi

#=====================================#
# LS colors                           #
#=====================================#

export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.7z=01;31:*.xz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.flac=01;35:*.mp3=01;35:*.mpc=01;35:*.ogg=01;35:*.wav=01;35:';

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

function scmbranch {
    if [[ "$(id -u)" != "0" ]] && [[ $SCMENABLED -eq 1 ]]; then
        if which git > /dev/null 2>&1; then
            if git rev-parse > /dev/null 2>&1; then
                GITBRANCH=$(git symbolic-ref HEAD 2>/dev/null)
                GITBRANCH=${GITBRANCH/refs\/heads\//}
                GITDIRTY=''
                if [[ $SCMDIRTY -eq 1 ]]; then
                    # if has unstaged changes
                    git diff --no-ext-diff --quiet --exit-code || GITDIRTY=" *"
                    # if only has staged changes
                    if [[ "$GITDIRTY" = "" ]]; then
                        git diff --staged --no-ext-diff --quiet --exit-code || GITDIRTY=" +"
                    fi
                fi
                if [[ "${GITBRANCH}" = "master" ]]; then
                    GITBRANCH="${PSCOL}─(%{%F{yellow}%}%Bgit%b${PSCOL})─(%{%F{green}%}${GITBRANCH}${GITDIRTY}${PSCOL})"
                elif [[ "${GITBRANCH}" = "" ]]; then
                    GITBRANCH="${PSCOL}─(%{%F{yellow}%}%Bgit%b${PSCOL})─(%{%F{red}%}$(git rev-parse --short HEAD)...${GITDIRTY}${PSCOL})"
                else
                    GITBRANCH="${PSCOL}─(%{%F{yellow}%}%Bgit%b${PSCOL})─(%{%F{cyan}%}${GITBRANCH}${GITDIRTY}${PSCOL})"
                fi
                echo -ne ${GITBRANCH}
            fi
        fi
        if which hg > /dev/null 2>&1; then
            if hg branch > /dev/null 2>&1; then
                HGBRANCH=$(hg branch 2>/dev/null)
                HGDIRTY=
                if [[ $SCMDIRTY -eq 1 ]]; then
                    [[ "$(hg status -n | wc -l)" == "0" ]] || HGDIRTY=" *"
                fi
                if [[ "${HGBRANCH}" = "default" ]]; then
                    HGBRANCH="${PSCOL}─(%{%F{yellow}%}%Bhg%b${PSCOL})─(%{%F{green}%}${HGBRANCH}${HGDIRTY}${PSCOL})"
                else
                    HGBRANCH="${PSCOL}─(%{%F{yellow}%}%Bhg%b${PSCOL})─(%{%F{cyan}%}${HGBRANCH}${HGDIRTY}${PSCOL})"
                fi
                echo -ne ${HGBRANCH}
            fi
        fi
        if which svn > /dev/null 2>&1; then
            if svn info > /dev/null 2>&1; then
                SVNREVISION=$(svn info | sed -ne 's/^Revision: //p')
                if [[ $SCMDIRTY -eq 1 ]]; then
                    [[ "$(svn status | wc -l)" == "0" ]] || SVNDIRTY=" *"
                fi
                SVNBRANCH="${PSCOL}─(%{%F{yellow}%}%Bsvn%b${PSCOL})─(%{%F{green}%}${SVNREVISION}${SVNDIRTY}${PSCOL})"
                echo -ne ${SVNBRANCH}
            fi
        fi
        if which bzr > /dev/null 2>&1; then
            if bzr nick > /dev/null 2>&1; then
                BZRREVISION=$(bzr revno)
                if [[ $SCMDIRTY -eq 1 ]]; then
                    [[ "$(bzr status | wc -l)" == "0" ]] || BZRDIRTY=" *"
                fi
                BZRBRANCH="${PSCOL}─(%{%F{yellow}%}%Bbzr%b${PSCOL})─(%{%F{green}%}${BZRREVISION}${BZRDIRTY}${PSCOL})"
                echo -ne ${BZRBRANCH}
            fi
        fi
    fi
}

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
    if [[ "$(id -u)" != "0" ]]; then
        if [[ $PWD =~ \/herecura ]]; then
            FLDCOL="%{%F{yellow}%}%B%U${folder}%u%b"
        elif [[ $PWD =~ \/scripts ]]; then
            FLDCOL="%{%F{blue}%}%B%U${folder}%u%b"
        elif [[ $PWD =~ \/vimfiles ]]; then
            FLDCOL="%{%F{purple}%}%B%U${folder}%u%b"
        elif [[ $PWD =~ \/devel ]]; then
            FLDCOL="%{%F{white}%}%B%U${folder}%u%b"
        fi
    fi

    if [[ "${FLDCOL}" = "" ]]; then
        if [[ $PWD =~ ^\/etc ]]; then
            FLDCOL="%{%F{red}%}%B%U${folder}%u%b"
        elif [[ $PWD =~ ^\/var/log ]]; then
            FLDCOL="%{%F{red}%}%B%U${folder}%u%b"
        else
            FLDCOL="%{%F{cyan}%}%B${folder}%b"
        fi
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

#=====================================#
# Session colors tty/ssh/screen       #
#=====================================#

if [[ "$STY" != "" ]]; then
    # screen
    SESSCOL='%{%F{cyan}%}%B%*%b'
elif [[ "$SSH_CLIENT" != "" ]]; then
    # SSH
    SESSCOL='%{%F{red}%}%B%*%b'
else
    SESSCOL='%*'
fi

#=====================================#
# Configure prompt                    #
#=====================================#

setopt prompt_subst
PROMPT='${PSCOL}┌─┤%(?,%F{green}%}%B●%b,%F{red}%}%B●%b)${PSCOL}├$(userinfo)─┤$(fldcol)${PSCOL}├$(scmbranch)─╼
└╼ %{%F{reset}%}'
