function sudocode --wraps sudoedit --description "Edit files as superuser through Remote-SSH"
    SUDO_EDITOR="$(which code) --wait" sudoedit $argv
end
