test $__os = Darwin; or return

# Point fish at OrbStack's completion directory
set -l orbstack_completions /Applications/OrbStack.app/Contents/Resources/completions/fish
if test -d $orbstack_completions; and not contains $orbstack_completions $fish_complete_path
    set -p fish_complete_path $orbstack_completions
end
