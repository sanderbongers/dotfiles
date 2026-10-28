function composer --wraps composer --description "alias composer=symfony composer"
    if command -q symfony
        symfony composer $argv
    else
        command composer $argv
    end
end
