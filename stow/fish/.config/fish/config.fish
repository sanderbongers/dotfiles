set -gx EDITOR (command -q nvim && echo nvim || echo vim)
set -gx ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX true
set -gx LANG en_GB.UTF-8

set -l paths /usr/sbin ~/.local/bin
command -q composer; and set -a paths ~/.composer/vendor/bin
command -q asdf; and set -a paths ~/.asdf/shims
fish_add_path -g $paths

for file in $__fish_config_dir/config.local.fish
    test -r $file; and source $file
end
