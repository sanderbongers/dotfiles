if status --is-interactive
    if test -d /opt/homebrew/opt/findutils/libexec/gnubin
        fish_add_path -g /opt/homebrew/opt/findutils/libexec/gnubin
    else if test -d /usr/local/opt/findutils/libexec/gnubin
        fish_add_path -g /usr/local/opt/findutils/libexec/gnubin
    end
end
