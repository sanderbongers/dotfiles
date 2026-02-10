if command -q symfony
    function composer --wraps composer --description "alias composer=symfony composer"
        symfony composer $argv
    end
end
