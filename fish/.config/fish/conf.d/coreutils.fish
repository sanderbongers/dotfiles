if test -d /opt/homebrew/opt/coreutils/libexec/gnubin
    fish_add_path -g /opt/homebrew/opt/coreutils/libexec/gnubin
else if test -d /usr/local/opt/coreutils/libexec/gnubin
    fish_add_path -g /usr/local/opt/coreutils/libexec/gnubin
end
