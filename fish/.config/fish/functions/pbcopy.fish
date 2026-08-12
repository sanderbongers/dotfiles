function pbcopy --description "Copy stdin to the clipboard, with fallback to OSC 52 when pbcopy doesn't exist"
    if command -q pbcopy
        command pbcopy $argv
    else
        set -l b64 (base64 | tr -d '\n')
        printf '\e]52;c;%s\a' $b64 >/dev/tty
    end
end
