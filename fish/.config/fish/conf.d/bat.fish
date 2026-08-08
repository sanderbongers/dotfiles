status is-interactive; or return

if command -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -plman --pager=\"less -R -K --header=1,1 --file-size\"'"
end
