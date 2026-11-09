# Spoločné aliasy pre oba notebooky. Hardvér patrí do aliases.local.fish.
# Starší notebook používa ~/Projects, tento ~/projects; funguj na oboch.
function projekty --description 'Prejsť do priečinka s projektmi'
    if test -d "$HOME/Projects"
        cd "$HOME/Projects"
    else if test -d "$HOME/projects"
        cd "$HOME/projects"
    else
        printf '%s\n' 'Priečinok s projektmi neexistuje.' >&2
        return 1
    end
end

alias e='nvim'
alias ls='ls --color=auto --quoting-style=literal'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias hidden='ls -d .*'
alias fonty='fc-list'
alias nainstalovanePac='pacman -Qen'
alias nainstalovaneAur='pacman -Qem'
alias torrent='transmission-cli'
alias v='mpv'
alias o='sxiv'
alias D='cd ~/Downloads'
alias V='cd ~/Videos'
alias s='cd ~/scripts'
alias z='zathura'
alias monitory='nwg-displays'
alias restartbar='pkill -USR2 -u (id -u) -x waybar'
alias g='git'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
