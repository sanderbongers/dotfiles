command -q symfony; or return

function composer --wraps composer --description "alias composer=symfony composer"
    symfony composer $argv
end
