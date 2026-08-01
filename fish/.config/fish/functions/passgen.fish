function passgen --description "Generate a random password"
    set -l upper_chars (string split '' 'ABCDEFGHJKLMNPQRSTUVWXYZ')
    set -l lower_chars (string split '' 'abcdefghijkmnopqrstuvwxyz')
    set -l digits (string split '' '23456789')
    set -l symbols (string split '' '!@#$%._-')

    while true
        set -l bytes (string split -n ' ' (od -An -N34 -tu1 /dev/urandom))
        set -l upper
        set -l lower

        # Reject uneven remainders so every character is equally likely.
        for byte in $bytes[1..16]
            test $byte -lt 240; or continue
            set -a upper $upper_chars[(math "$byte % 24 + 1")]
            test (count $upper) -eq 5; and break
        end

        for byte in $bytes[17..32]
            test $byte -lt 250; or continue
            set -a lower $lower_chars[(math "$byte % 25 + 1")]
            test (count $lower) -eq 10; and break
        end

        test (count $upper) -eq 5; or continue
        test (count $lower) -eq 10; or continue

        set -l digit $digits[(math "$bytes[33] % 8 + 1")]
        set -l symbol $symbols[(math "$bytes[34] % 8 + 1")]

        string join '' $upper $symbol $lower[1..5] $digit $lower[6..10]
        return
    end
end
