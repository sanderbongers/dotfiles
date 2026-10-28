function mv --description "alias mv=mv -v"
    if status is-interactive
        command mv -v $argv
    else
        command mv $argv
    end
end
