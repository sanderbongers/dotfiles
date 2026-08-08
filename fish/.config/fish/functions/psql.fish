if status is-interactive; and command -q pgcli
    function psql --wraps pgcli --description "alias psql=pgcli"
        pgcli $argv
    end
end
