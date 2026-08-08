if status is-interactive
    function rm --description "alias rm=rm -v"
        command rm -v $argv
    end
end
