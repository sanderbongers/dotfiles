# Adapted from fish's embedded man function: identical fish-manpage handling, but renders
# through man-db's gman when available, since macOS's mandoc mishandles GNU (groff) pages.
function man --description "Format and display manual pages, preferring GNU man-db"
    set -l manpath
    if __fish_tried_to_embed_manpages
        if not set -q argv[2] &&
                status list-files "man/man1/$(__fish_canonicalize_builtin $argv).1" &>/dev/null
            __fish_print_help $argv[1]
            return
        end
    else if set -l fish_manpath (path filter -d $__fish_man_dir)
        # Prepend fish's man directory.
        set manpath $fish_manpath (
        if set -q MANPATH
            string join -- \n $MANPATH
        else
            # Trailing empty string to keep the system default path.
            echo ''
        end
    )
        if test (count $argv) -eq 1
            set argv (__fish_canonicalize_builtin $argv)
        end
    end
    set -q manpath[1]
    and set -lx MANPATH $manpath

    if command -q gman
        # Emit overstrike like BSD man instead of SGR escapes, which col in MANPAGER mangles.
        set -lx GROFF_NO_SGR 1
        command gman $argv
    else
        command man $argv
    end
end
