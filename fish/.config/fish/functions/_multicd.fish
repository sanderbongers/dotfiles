function _multicd --description "Go up a number of directories (... -> cd ../../, .... -> cd ../../../, etc.)"
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
