set -gx EDITOR (command -q nvim && echo nvim || echo vim)
set -gx ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX true
set -gx LANG en_GB.UTF-8

fish_add_path -g ~/.local/bin

# @fish-lsp-disable-next-line 1004
test -f $__fish_config_dir/config.local.fish; and source $__fish_config_dir/config.local.fish

# @fish-lsp-disable-next-line 1004
test -f ~/.iterm2_shell_integration.fish; and source ~/.iterm2_shell_integration.fish
