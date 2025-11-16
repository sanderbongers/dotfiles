set -gx FZF_DEFAULT_OPTS "--height 100% --reverse --multi --exact --preview-window down:60%:hidden --bind 'ctrl-/:toggle-preview+transform-preview-label:echo [ {} ]' --bind 'ctrl-z:ignore'"
set -gx FZF_CTRL_R_OPTS "--header 'Copy: ⌃y' --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort' --bind 'ctrl-r:ignore,ctrl-/:ignore'"

# Use ripgrep to find files
if command -q rg
    set -gx FZF_DEFAULT_COMMAND "command rg --ignore-file=$HOME/.rgignore --files \$dir 2>/dev/null | sed 's@^\./@@'"
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
end

# Use fd to find directories
set -l fd (command -s fd || command -s fdfind)
if command -q $fd
    set -gx FZF_ALT_C_COMMAND "$fd --ignore-file=$HOME/.rgignore --type directory"
    set -gx FZF_ALT_C_OPTS "--header 'Toggle hidden: ⌃h' --bind 'start:execute-silent(fzf_cd_toggle init)' --bind 'ctrl-h:transform-query(fzf_cd_toggle pre {q})+reload(eval {q})+transform-query(fzf_cd_toggle post)'"
end

# Use bat to colorize previews
if command -q bat
    set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS --preview 'test -f {} && bat --color always --line-range :500 {} || eza -1 --level=1 --color=never {}' --bind 'focus:transform-preview-label:echo [ {} ]'"
end
