function passgen --description "Generate a random password"
    set -l password (LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c 20)

    printf '%s' $password | pbcopy; or return
    printf 'Copied to clipboard: %s\n' $password
end
