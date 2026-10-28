function vim --wraps nvim --description "alias vim=nvim"
    if status is-interactive; and command -q nvim
        nvim $argv
    else
        command vim $argv
    end
end
