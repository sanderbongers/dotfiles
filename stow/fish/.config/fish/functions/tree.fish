status is-interactive; and command -q tree; or return

function tree --description "List directory contents in a tree-like format"
    command tree -a -I .git --gitignore -C $argv
end
