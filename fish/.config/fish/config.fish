set -gx EDITOR (command -q nvim && echo nvim || echo vim)
set -gx ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX true
set -gx LANG en_GB.UTF-8

set -l user_paths ~/.local/bin
command -q composer; and set -a user_paths ~/.composer/vendor/bin
command -q asdf; and set -a user_paths ~/.asdf/shims
fish_add_path -g $user_paths

# @fish-lsp-disable-next-line 1004
test -f $__fish_config_dir/config.local.fish; and source $__fish_config_dir/config.local.fish

# @fish-lsp-disable-next-line 1004
test -f ~/.iterm2_shell_integration.fish; and source ~/.iterm2_shell_integration.fish
