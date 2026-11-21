function __completion_bypasses_wrapper --argument-names replacement --description "Use native completions for bypasses"
    set -l tokens (commandline -xpc)
    string match -q '*/*' -- $tokens[1]; and return 0
    not command -q $replacement
end
