function console --wraps="symfony console" --description "alias console=symfony console"
    if not command -q symfony
        echo "console: the Symfony CLI is not installed" >&2
        return 127
    end
    symfony console $argv
end
