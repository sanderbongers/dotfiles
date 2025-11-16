if command -q mycli
    function mysql --wraps mycli --description "alias mysql=mycli"
        mycli $argv
    end
end
