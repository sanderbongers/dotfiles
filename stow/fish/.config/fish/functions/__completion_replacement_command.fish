function __completion_replacement_command --argument-names replacement --description "Complete wrapper target"
    set -l tokens (commandline -xpc)
    set tokens[1] $replacement
    complete -C (string join ' ' -- (string escape -- $tokens) (commandline -ct))
end
