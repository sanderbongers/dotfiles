abbr -a dotdot --regex '^\.\.+$' --function _multicd
abbr -a s sudo

if string match -q (uname) Darwin
    abbr -a d cd "~/Downloads"
    abbr -a p cd "~/Projects"
end
