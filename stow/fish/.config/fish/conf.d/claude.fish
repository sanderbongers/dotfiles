# Workaround for Claude Desktop's terminal not answering fish's terminal queries
status is-interactive; or return
test "$TERM_PROGRAM" = claude-desktop; or return
contains -- no-query-term $fish_features; and return
isatty stdin; and isatty stdout; or return
set -l fish (status fish-path)
# Claude Desktop starts fish with -l, restarting any other invocation would drop its arguments.
set -l executable (string replace -rf -- ' -l$' '' (command ps -o args= -p $fish_pid)); or return
test "$(path resolve -- $executable)" = "$(path resolve -- $fish)"; or return
set -gx fish_features $fish_features no-query-term
exec $fish --login
