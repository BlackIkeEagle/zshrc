#######################################
# BlackEagle's .zshrc                 #
#######################################

#=====================================#
# Add .bin if it exists               #
#=====================================#

[ -d $HOME/.bin ] && PATH=$HOME/.bin:$PATH

#=====================================#
# Keybindings                         #
#=====================================#
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\ee[C" forward-word
bindkey "\ee[D" backward-word
bindkey "\^H" backward-delete-word
# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line

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
# zsh vi mode
#bindkey -v
#bindkey '^R' history-incremental-search-backward

#=====================================#
# Load zsh modules                    #
#=====================================#

autoload -Uz compinit
compinit

# completion options
zstyle -e ':completion:*:(ssh|scp):*' hosts 'reply=(
	${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) \
		/dev/null)"}%%[# ]*}//,/ }
	${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
	${=${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*\**}:#*\?*}}
	)'

zstyle ':completion:*' menu select

#=====================================#
# Load config                         #
#=====================================#

if [ -e $HOME/.zshrc.config ]; then
    source $HOME/.zshrc.config
elif [ -e /etc/zsh/zshrc.config ]; then
    source /etc/zsh/zshrc.config
fi

#=====================================#
# Default promt colors                #
#=====================================#
# defaults
[ -z $PSCOL ] && PSCOL='%{%F{yellow}%}'
[ -z $USRCOL ] && USRCOL='%{%F{yellow}%}'
[ -z $HSTCOL ] && HSTCOL='%{%F{white}%}'
# default flags
[ -z $SCMENABLED ] && SCMENABLED=1
[ -z $SCMDIRTY ] && SCMDIRTY=1

if [ "$(id -u)" = "0" ]; then
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

#=====================================#
# FUNCTIONS                           #
#=====================================#

function scmbranch {
	if [ "$(id -u)" != "0" ] && [ $SCMENABLED -eq 1 ]; then
		if which git > /dev/null 2>&1; then
			if git rev-parse > /dev/null 2>&1; then
				GITBRANCH=$(git symbolic-ref HEAD 2>/dev/null)
				GITBRANCH=${GITBRANCH/refs\/heads\//}
				GITDIRTY=''
				if [ $SCMDIRTY -eq 1 ]; then
					git diff --no-ext-diff --quiet --exit-code || GITDIRTY=" *"
				fi
				if [ "${GITBRANCH}" = "master" ]; then
					GITBRANCH="${PSCOL}─(%{%F{yellow}%}%Bgit%b${PSCOL})─(%{%F{green}%}${GITBRANCH}${GITDIRTY}${PSCOL})"
				elif [ "${GITBRANCH}" = "" ]; then
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
				if [ $SCMDIRTY -eq 1 ]; then
					[[ "$(hg status -n | wc -l)" == "0" ]] || HGDIRTY=" *"
				fi
				if [ "${HGBRANCH}" = "default" ]; then
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
				if [ $SCMDIRTY -eq 1 ]; then
					[[ "$(svn status | wc -l)" == "0" ]] || SVNDIRTY=" *"
				fi
				SVNBRANCH="${PSCOL}─(%{%F{yellow}%}%Bsvn%b${PSCOL})─(%{%F{green}%}${SVNREVISION}${SVNDIRTY}${PSCOL})"
				echo -ne ${SVNBRANCH}
			fi
		fi
	fi
}

function fldcol {
	if [ "$(id -u)" != "0" ]; then
		if [[ $PWD =~ \/herecura ]]; then
			FLDCOL='%{%F{yellow}%}%B%U%~%u%b'
		elif [[ $PWD =~ \/scripts ]]; then
			FLDCOL='%{%F{blue}%}%B%U%~%u%b'
		elif [[ $PWD =~ \/vimfiles ]]; then
			FLDCOL='%{%F{purple}%}%B%U%~%u%b'
		elif [[ $PWD =~ \/devel ]]; then
			FLDCOL='%{%F{white}%}%B%U%~%u%b'
		fi
	fi

	if [ "${FLDCOL}" = "" ]; then
		if [[ $PWD =~ ^\/etc ]]; then
			FLDCOL='%{%F{red}%}%B%U%~%u%b'
		elif [[ $PWD =~ ^\/var/log ]]; then
			FLDCOL='%{%F{red}%}%B%U%~%u%b'
		else
			FLDCOL='%{%F{cyan}%}%B%~%b'
		fi
	fi
	echo -ne ${FLDCOL}
}

#=====================================#
# Session colors tty/ssh/screen       #
#=====================================#

if [ "$STY" != "" ]; then
	# screen
	SESSCOL='%{%F{cyan}%}%B%*%b'
elif [ "$SSH_CLIENT" != "" ]; then
	# SSH
	SESSCOL='%{%F{red}%}%B%*%b'
else
	SESSCOL='%*'
fi

setopt prompt_subst
PROMPT='${PSCOL}┌─┤%(?,%F{green}%}%B●%b,%F{red}%}%B●%b)${PSCOL}├─┤${SESSCOL}${PSCOL}├─┤${USRCOL}%B%n%b${PSCOL} @ ${HSTCOL}%B%M%b${PSCOL}├─┤$(fldcol)${PSCOL}├$(scmbranch)─╼
└╼ %{%F{reset}%}'
