function cdroot --description "Go up to the root directory of the current project"
    set git_root (git rev-parse --show-toplevel)

    cd $git_root
end
