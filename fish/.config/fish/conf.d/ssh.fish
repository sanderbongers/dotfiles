status is-interactive; or return

set -q __ssh_key_checked; and return
set -gx __ssh_key_checked 1

set -l ssh_key ~/.ssh/id_ed25519

# Store SSH key passphrase in keychain.
if test $__os = Darwin
    if not ssh-add -l >/dev/null
        test -f $ssh_key; and ssh-add --apple-use-keychain $ssh_key
    end
else if test $__os = Linux
    if command -q keychain
        if test -f $ssh_key
            keychain --quiet --quick --eval $ssh_key \
                | string replace -a 'set -x -U ' 'set -gx ' \
                | source
        end
    end
end
