if command -q mycli
    function mysql --wraps mycli --description "alias mysql=mycli"
        command mycli --no-warn $argv
    end
end
