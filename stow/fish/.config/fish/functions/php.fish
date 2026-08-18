command -q symfony; or return

function php --wraps php --description "alias php=symfony php"
    symfony php $argv
end
