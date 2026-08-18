status is-interactive; and command -q pgcli; or return

function psql --wraps pgcli --description "alias psql=pgcli"
    pgcli $argv
end
