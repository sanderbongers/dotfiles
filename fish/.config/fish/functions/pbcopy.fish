function pbcopy --description "Copy stdin to the clipboard, with fallback to OSC 52 when pbcopy doesn't exist"
    if command -q pbcopy
        command pbcopy $argv
    else
        begin
            printf '\e]52;c;'
            base64 | tr -d '\n'
            printf '\a'
        end >/dev/tty
    end
end
