status is-interactive; and command -q mycli; or return

function mysql --wraps mycli --description "alias mysql=mycli"
    command mycli --no-warn $argv
end
