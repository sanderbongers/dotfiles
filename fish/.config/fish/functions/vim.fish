if command -q nvim
    function vim --wraps nvim --description "alias vim=nvim"
        nvim $argv
    end
end
