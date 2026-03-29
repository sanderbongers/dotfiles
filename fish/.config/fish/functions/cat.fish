if command -q bat
    function cat --wraps bat --description "alias cat=bat"
        bat $argv --no-pager
    end
end
