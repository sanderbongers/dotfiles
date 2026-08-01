function passgen --description "Generate a random password"
    while true
        set -l password (LC_ALL=C tr -dc 'A-HJ-NP-Za-km-z2-9!._-' </dev/urandom | head -c 16)

        string match -qr '[A-Z]' -- $password; or continue
        string match -qr '[a-z]' -- $password; or continue
        string match -qr '[2-9]' -- $password; or continue
        string match -qr '[!._-]' -- $password; or continue

        echo $password
        return
    end
end
