function cdroot --description "Go up to the root directory of the current project"
    set -l git_root (git rev-parse --show-toplevel)
    or return

    cd $git_root
end
