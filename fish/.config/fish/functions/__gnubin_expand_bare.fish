function __gnubin_expand_bare --description "Abbr expansion: like __gnubin_expand but without flags, for contexts like man"
    command -q g$argv[1]; or return 1
    echo g$argv[1]
end
