function trash --description "alias trash=trash -v"
    if status is-interactive
        command trash -v $argv
    else
        command trash $argv
    end
end
