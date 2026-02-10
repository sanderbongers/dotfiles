if command -q symfony
    function console --wraps="symfony console" --description "alias console=symfony console"
        symfony console $argv
    end
end
