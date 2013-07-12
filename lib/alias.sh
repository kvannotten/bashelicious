# Bashelicious aliases
alias ls="ls -FG"
alias ll="ls -lh"
alias la="ls -Hlha"
alias lsd='ls -l | grep "^d"'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias ..="cd .."
alias ...="cd ../.."
alias -- -="cd -"
alias nano="nano -f"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0" # change to en1 if needed
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
