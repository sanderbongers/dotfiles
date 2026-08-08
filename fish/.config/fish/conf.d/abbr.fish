status is-interactive; or return

abbr -a dotdot --regex '^\.\.+$' --function _multicd
abbr -a s sudo

if test (uname) = Darwin
    abbr -a d cd "~/Downloads"
    abbr -a p cd "~/Projects"
end
