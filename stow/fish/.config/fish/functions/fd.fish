function fd --description "alias fd=fd --hidden --ignore-file=~/.rgignore"
    if status is-interactive
        command fd --hidden --ignore-file="$HOME/.rgignore" $argv
    else
        command fd $argv
    end
end
