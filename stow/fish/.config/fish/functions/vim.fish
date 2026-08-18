status is-interactive; and command -q nvim; or return

function vim --wraps nvim --description "alias vim=nvim"
    nvim $argv
end
