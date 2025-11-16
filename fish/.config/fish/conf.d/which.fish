if test -d /opt/homebrew/opt/gnu-which/libexec/gnubin
    fish_add_path -g /opt/homebrew/opt/gnu-which/libexec/gnubin
else if test -d /usr/local/opt/gnu-which/libexec/gnubin
    fish_add_path -g /usr/local/opt/gnu-which/libexec/gnubin
end
