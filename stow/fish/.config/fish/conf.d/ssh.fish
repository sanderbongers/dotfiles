status is-interactive; or return

set -q __ssh_key_setup_done; and return
set -gx __ssh_key_setup_done true

set -l ssh_key ~/.ssh/id_ed25519
test -f $ssh_key; or return

# Load the key into the agent and the passphrase from the keychain.
switch $__os
    case Darwin
        set -l fingerprint (ssh-keygen -lf $ssh_key | string split ' ')[2]

        ssh-add -l 2>/dev/null | string match -q "*$fingerprint*"
        or ssh-add --apple-use-keychain $ssh_key
    case Linux
        command -q keychain; or return

        # @fish-lsp-disable-next-line 7001
        keychain --quiet --quick --eval $ssh_key \
            | string replace -a 'set -x -U ' 'set -gx ' \
            | source
end
