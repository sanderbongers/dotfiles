command -q symfony; or return

function console --wraps="symfony console" --description "alias console=symfony console"
    symfony console $argv
end
