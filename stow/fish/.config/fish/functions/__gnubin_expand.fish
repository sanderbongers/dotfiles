function __gnubin_expand --description "Abbr expansion: replace a GNU tool name with its g-prefixed Homebrew binary"
    command -q g$argv[1]; or return 1
    if test $argv[1] = grep
        # Display colors for grep.
        echo ggrep --color=auto
    else
        echo g$argv[1]
    end
end
