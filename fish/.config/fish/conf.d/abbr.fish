status is-interactive; or return

abbr -a dotdot --regex '^\.\.+$' --function _multicd

if test $__os = Darwin
    abbr -a d cd "~/Downloads"
    abbr -a p cd "~/Projects"
end
