status is-interactive; or return

set -l os (uname)
set -l ssh_key ~/.ssh/id_ed25519

# Store SSH key passphrase in keychain
if string match -q $os Darwin
    if not ssh-add -l >/dev/null
        test -f $ssh_key; and ssh-add --apple-use-keychain $ssh_key
    end
else if string match -q $os Linux
    if command -q keychain
        set -l keychain_env (keychain --quiet --quick --eval $ssh_key)
        set -gx SSH_AUTH_SOCK (echo $keychain_env | grep SSH_AUTH_SOCK | cut -d= -f2)
        set -gx SSH_AGENT_PID (echo $keychain_env | grep SSH_AGENT_PID | cut -d= -f2)
    end
end
