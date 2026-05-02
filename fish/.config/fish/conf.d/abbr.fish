abbr -a dotdot --regex '^\.\.+$' --function _multicd
abbr -a s sudo
abbr -a sv sudo vim

if string match -q (uname) Darwin
    abbr -a d cd "~/Downloads"
    abbr -a p cd "~/Projects"
else if string match -q (uname) Linux
    abbr -a ss sudo systemctl
    abbr -a sj sudo journalctl
end
