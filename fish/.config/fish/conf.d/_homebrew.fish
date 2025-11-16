string match -q (uname) Darwin; or return

command -q brew; or set -x PATH "/opt/homebrew/bin:$PATH"
if command -q brew
    eval "$(brew shellenv)"

    set -gx HOMEBREW_BUNDLE_DUMP_NO_VSCODE true
    set -gx HOMEBREW_BUNDLE_NO_UPGRADE true
    set -gx HOMEBREW_EVAL_ALL true
    set -gx HOMEBREW_NO_ENV_HINTS true

    abbr --add bi "brew install"
    abbr --add bs "brew services"
    abbr --add bu "brew uninstall"
end
