if status is-interactive; and command -q tree
    function tree --description "List directory contents in a tree-like format"
        command tree -a --gitignore -C $argv
    end
end
