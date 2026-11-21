#!/usr/bin/env -S fish --no-config

set -l config (path resolve (status dirname)/../stow/fish/.config/fish)
set -l tmp (mktemp -d); or exit 1
function cleanup --on-event fish_exit --inherit-variable tmp
    /bin/rm -rf -- $tmp
end

mkdir $tmp/bin; or exit 1
for name in cat vim gtool bat nvim
    ln -s /usr/bin/true $tmp/bin/$name; or exit 1
end
set -gx PATH $tmp/bin
set -g fish_function_path $config/functions
set -g fish_complete_path $config/completions
complete -c bat -l replacement
complete -c nvim -l replacement
complete -c gtool --wraps fixture_tool
complete -c fixture_tool -l inherited

function assert_completion --argument-names input expected forbidden
    set -l result (complete -C $input); or exit 1
    set result (string replace -r '\t.*$' '' -- $result)
    if not contains -- $expected $result; or contains -- $forbidden $result
        printf 'Unexpected completions for %s: expected %s without %s\n' $input $expected $forbidden >&2
        exit 1
    end
end

assert_completion 'cat -' --replacement -l
assert_completion 'vim -' --replacement -C
for prefix in 'command ' 'command -- ' "$tmp/bin/"
    assert_completion "$prefix"'cat -' -l --replacement
    assert_completion "$prefix"'vim -' -C --replacement
end
assert_completion 'command --he' --help --replacement
assert_completion 'command ca' cat --replacement
for input in 'gtool --in' 'command gtool --in' 'command -- gtool --in'
    assert_completion $input --inherited --replacement
end

/bin/rm $tmp/bin/bat $tmp/bin/nvim; or exit 1
assert_completion 'cat -' -l --replacement
assert_completion 'vim -' -C --replacement

echo 'ok - Native, replacement, command-prefix, missing-replacement and inherited completions'
