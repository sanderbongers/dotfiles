if test -d /opt/homebrew/opt/gnu-tar/libexec/gnubin
    fish_add_path -g /opt/homebrew/opt/gnu-tar/libexec/gnubin
else if test -d /usr/local/opt/gnu-tar/libexec/gnubin
    fish_add_path -g /usr/local/opt/gnu-tar/libexec/gnubin
end
