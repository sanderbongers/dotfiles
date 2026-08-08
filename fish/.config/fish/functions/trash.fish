if status is-interactive
    function trash --description "alias trash=trash -v"
        command trash -v $argv
    end
end
