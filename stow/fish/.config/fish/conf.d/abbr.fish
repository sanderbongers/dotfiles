status is-interactive; or return

abbr -a dotdot --regex '^\.\.+$' --function __dotdot_expand

if test $__os = Darwin
    abbr -a d cd "~/Downloads"
    abbr -a p cd "~/Projects"
end
