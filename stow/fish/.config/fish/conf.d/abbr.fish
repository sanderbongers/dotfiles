status is-interactive; or return

abbr -a dotdot --regex '^\.\.+$' --function __dotdot_expand

if test $__os = Darwin
    abbr -a dev cd "~/Developer"
    abbr -a dl cd "~/Downloads"
end
