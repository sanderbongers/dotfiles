function php --wraps php --description "alias php=symfony php"
    if command -q symfony
        symfony php $argv
    else
        command php $argv
    end
end
