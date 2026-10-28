function cat --wraps bat --description "alias cat=bat"
    if status is-interactive; and command -q bat
        bat $argv --no-pager
    else
        command cat $argv
    end
end
