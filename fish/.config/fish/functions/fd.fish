if status is-interactive
    function fd --description "alias fd=fd --hidden --ignore-file=~/.rgignore"
        command fd --hidden --ignore-file=~/.rgignore $argv
    end
end
