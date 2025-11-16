if test -d /opt/homebrew/opt/grep/libexec/gnubin
    fish_add_path -g /opt/homebrew/opt/grep/libexec/gnubin
else if test -d /usr/local/opt/grep/libexec/gnubin
    fish_add_path -g /usr/local/opt/grep/libexec/gnubin
end
