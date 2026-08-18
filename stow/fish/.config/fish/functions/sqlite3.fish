status is-interactive; and command -q litecli; or return

function sqlite3 --wraps litecli --description "alias sqlite3=litecli"
    command litecli $argv
end
