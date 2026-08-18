status is-interactive; and command -q bat; or return

function cat --wraps bat --description "alias cat=bat"
    bat $argv --no-pager
end
