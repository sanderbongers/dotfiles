function cp --description "alias cp=cp -v"
    if status is-interactive
        command cp -v $argv
    else
        command cp $argv
    end
end
