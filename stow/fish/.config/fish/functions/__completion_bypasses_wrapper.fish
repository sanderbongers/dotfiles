function __completion_bypasses_wrapper --description "True when invoked by path, bypassing a wrapper like vim=nvim, so the real binary's completions apply"
    string match -q '*/*' -- (commandline -opc)[1]
end
