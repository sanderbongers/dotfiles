if status is-interactive
    function fd --description "alias fd=fd --hidden --ignore-file$HOME/.rgignore"
        command fd --hidden --ignore-file="$HOME/.rgignore" $argv
    end
end
