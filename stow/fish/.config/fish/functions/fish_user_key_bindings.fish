function fish_user_key_bindings
    if command -q fzf
        fzf --fish | source
    end

    bind alt-left backward-word
    bind alt-right forward-word
    bind alt-backspace backward-kill-word
    bind shift-backspace backward-kill-bigword
end
