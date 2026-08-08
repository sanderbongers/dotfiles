test $__os = Darwin; or return

if command -q brew
    # Load shell integration, cached until brew is updated.
    set -l cache $__fish_cache_dir/brew_shellenv.fish
    if not test -f $cache; or test (command -s brew) -nt $cache
        mkdir -p $__fish_cache_dir
        brew shellenv fish >$cache
    end
    source $cache

    set -gx HOMEBREW_BUNDLE_DUMP_NO_VSCODE true
    set -gx HOMEBREW_BUNDLE_NO_UPGRADE true
    set -gx HOMEBREW_NO_ENV_HINTS true

    if status is-interactive
        abbr -a bi "brew install"
        abbr -a bs "brew services"
        abbr -a bu "brew uninstall"
    end
end
