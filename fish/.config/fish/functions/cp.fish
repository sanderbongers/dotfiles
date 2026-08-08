if status is-interactive
    function cp --description "alias cp=cp -v"
        command cp -v $argv
    end
end
