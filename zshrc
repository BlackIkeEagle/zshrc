HISTFILE=~/.zsh_history
HISTSIZE=4096
SAVEHIST=8192
setopt appendhistory autocd extendedglob
bindkey -v

autoload -Uz compinit
compinit

reset_color=[00m

PROMPT='%{%F{yellow}%}┌─┤%(?,%F{green}%}%B●%b,%F{red}%}%B●%b)%{%F{yellow}%}├─┤%*├─┤%B%n%b%{%F{yellow}%} @ %{%F{white}%}%B%M%b%{%F{yellow}%}├─┤%{%F{cyan}%}%B%~%b%{%F{yellow}%}├─╼
└╼ %{%F{reset}%}'
