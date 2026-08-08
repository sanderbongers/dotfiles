test (uname) = Darwin; or return

if command -q brew
    brew shellenv fish | source

    set -gx HOMEBREW_BUNDLE_DUMP_NO_VSCODE true
    set -gx HOMEBREW_BUNDLE_NO_UPGRADE true
    set -gx HOMEBREW_NO_ENV_HINTS true

    if status is-interactive
        abbr -a bi "brew install"
        abbr -a bs "brew services"
        abbr -a bu "brew uninstall"
    end
end
