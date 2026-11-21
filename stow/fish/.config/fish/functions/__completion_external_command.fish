function __completion_external_command --description "Complete command using the external executable"
    set -l tokens (commandline -xpc)
    set -e tokens[1]
    while set -q tokens[1]; and string match -q -- '-*' $tokens[1]
        set -e tokens[1]
    end

    if not contains -- "$tokens[1]" cat vim
        __fish_complete_subcommand
        return
    end

    set -l executable (command -s -- $tokens[1]); or return
    set tokens[1] $executable
    complete -C (string join ' ' -- (string escape -- $tokens) (commandline -ct))
end
