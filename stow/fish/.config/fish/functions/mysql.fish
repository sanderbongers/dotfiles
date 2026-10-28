function mysql --wraps mycli --description "alias mysql=mycli"
    if status is-interactive; and command -q mycli
        command mycli --no-warn $argv
    else
        command mysql $argv
    end
end
