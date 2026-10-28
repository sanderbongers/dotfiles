function sqlite3 --wraps litecli --description "alias sqlite3=litecli"
    if status is-interactive; and command -q litecli
        command litecli $argv
    else
        command sqlite3 $argv
    end
end
