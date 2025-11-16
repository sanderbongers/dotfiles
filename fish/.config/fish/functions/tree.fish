set -l alias tree
set -l description "List directory contents in a tree-like format"

if command -q eza
    function $alias --wraps eza --description $description
        eza --tree --all --git-ignore $argv
    end
else if command -q tree
    function $alias --wraps tree --description $description
        command tree -a --gitignore -C $argv
    end
end
