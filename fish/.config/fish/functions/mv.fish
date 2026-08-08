if status is-interactive
    function mv --description "alias mv=mv -v"
        command mv -v $argv
    end
end
