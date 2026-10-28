function tree --description "List directory contents in a tree-like format"
    if status is-interactive
        command tree -a -I .git --gitignore -C $argv
    else
        command tree $argv
    end
end
