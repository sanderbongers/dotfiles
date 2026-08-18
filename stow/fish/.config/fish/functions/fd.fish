status is-interactive; or return

function fd --description "alias fd=fd --hidden --ignore-file=~/.rgignore"
    command fd --hidden --ignore-file="$HOME/.rgignore" $argv
end
