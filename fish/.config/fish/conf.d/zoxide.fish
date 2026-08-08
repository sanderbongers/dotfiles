status is-interactive; or return

if command -q zoxide
    # Load shell integration, cached until zoxide is updated.
    set -l cache $__fish_cache_dir/zoxide_init.fish
    if not test -f $cache; or test (command -s zoxide) -nt $cache
        mkdir -p $__fish_cache_dir
        zoxide init fish >$cache
    end
    source $cache
end
