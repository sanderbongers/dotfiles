function ripgrep --description "ripgrep with fzf as interface and fuzzy filter"

    set -l rg_prefix "rg --no-config --no-heading --line-number --no-column --color=always --hidden --smart-case"
    if contains -- --no-ignore-vcs $argv
        set rg_prefix "$rg_prefix --no-ignore-vcs"
    end

    # Drop any flags from the arguments
    set -l argv (string match --invert -- '-*' $argv)

    # Remove any previous temporary files
    command rm -f $TMPDIR/rg-fzf-{r,f}

    : | FZF_DEFAULT_OPTS="" fzf \
        --ansi \
        --disabled \
        --query "$argv" \
        --height 100% \
        --reverse \
        --border none \
        --header "Toggle mode: ⌃r (ripgrep) | ⌃f (fzf)" \
        --bind "start:reload($rg_prefix {q})+unbind(ctrl-r)" \
        --bind "change:reload:sleep 0.05; $rg_prefix {q} || true" \
        --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > $TMPDIR/rg-fzf-r; command cat $TMPDIR/rg-fzf-f)" \
        --bind "ctrl-r:unbind(ctrl-r)+change-prompt(ripgrep> )+disable-search+reload($rg_prefix {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > $TMPDIR/rg-fzf-f; command cat $TMPDIR/rg-fzf-r)" \
        --prompt "ripgrep> " \
        --delimiter : \
        --preview "bat --style=default --color=always {1} --highlight-line {2}" \
        --preview-window "down,60%,~3,+{2}+3/3" \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --bind "enter:become(vim {1} +{2})"
end
