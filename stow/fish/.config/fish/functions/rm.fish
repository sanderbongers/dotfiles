function rm --description "alias rm=rm -v"
    if status is-interactive
        command rm -v $argv
    else
        command rm $argv
    end
end
