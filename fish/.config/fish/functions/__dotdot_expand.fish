function __dotdot_expand --description "Go up one directory per extra dot"
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
