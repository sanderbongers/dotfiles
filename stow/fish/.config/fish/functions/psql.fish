function psql --wraps pgcli --description "alias psql=pgcli"
    if status is-interactive; and command -q pgcli
        pgcli $argv
    else
        command psql $argv
    end
end
