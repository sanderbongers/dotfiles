if command -q symfony
    function php --wraps php --description "alias php=symfony php"
        symfony php $argv
    end
end
