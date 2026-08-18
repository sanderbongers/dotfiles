test $__os = Darwin; or return

set -l brew /opt/homebrew/bin/brew
if test -x $brew
    # Load shell integration, cached until brew is updated.
    # Keyed off the absolute path since brew is what puts itself on PATH.
    set -l cache $__fish_cache_dir/brew_shellenv.fish
    if not test -f $cache; or test $brew -nt $cache
        set -l tmp $cache.$fish_pid.tmp
        $brew shellenv fish >$tmp
        and command mv -f $tmp $cache; or command rm -f $tmp
    end
    test -f $cache; and source $cache

    set -gx HOMEBREW_BUNDLE_DUMP_NO_VSCODE true
    set -gx HOMEBREW_BUNDLE_NO_UPGRADE true
    set -gx HOMEBREW_NO_ENV_HINTS true

    if status is-interactive
        abbr -a bi "brew install"
        abbr -a bs "brew services"
        abbr -a bu "brew uninstall"
    end
end
