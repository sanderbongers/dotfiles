function __fish_tg_using_subcommand
    set -l tokens (commandline -opc)
    # Global options take no values, so the first non-option is the subcommand.
    for token in $tokens[2..-1]
        if not string match -q -- '-*' $token
            contains -- $token $argv
            return
        end
    end
    return 1
end

complete -c tg -f
complete -c tg -l help -d 'Show help and exit'
complete -c tg -n __fish_use_subcommand -l version -d 'Show version and exit'

complete -c tg -n __fish_use_subcommand -a download -d 'Save message photos'
complete -c tg -n __fish_use_subcommand -a get -d 'Fetch messages by ID as JSON'
complete -c tg -n __fish_use_subcommand -a groups -d 'List groups and channels as JSON'
complete -c tg -n __fish_use_subcommand -a chats -d 'List personal chats, groups and channels as JSON'
complete -c tg -n __fish_use_subcommand -a login -d 'Authenticate with Telegram'
complete -c tg -n __fish_use_subcommand -a messages -d 'Fetch recent messages, oldest first'
complete -c tg -n __fish_use_subcommand -a search -d 'Search messages, newest first'
complete -c tg -n __fish_use_subcommand -a thread -d 'Fetch a message and its replies'

complete -c tg -n '__fish_tg_using_subcommand download' -l dir -x \
    -a '(__fish_complete_directories)' -d 'Directory to save photos into (required)'
complete -c tg -n '__fish_tg_using_subcommand download' -l max-bytes -x -d 'Maximum photo size in bytes'
complete -c tg -n '__fish_tg_using_subcommand groups' -l type -x -a 'group channel all' -d 'Filter by dialog kind'
complete -c tg -n '__fish_tg_using_subcommand groups' -l limit -x -d 'Maximum number of dialogs'
complete -c tg -n '__fish_tg_using_subcommand chats' -l type -x \
    -a 'personal bot group channel all' -d 'Filter by dialog kind'
complete -c tg -n '__fish_tg_using_subcommand chats' -l limit -x -d 'Maximum number of dialogs'
complete -c tg -n '__fish_tg_using_subcommand login' -l phone -x -d 'Phone number in +country format'

complete -c tg -n '__fish_tg_using_subcommand get groups chats messages search thread' -l pretty -d 'Indent JSON output'
complete -c tg -n '__fish_tg_using_subcommand messages search' -l since -x \
    -d 'Include messages newer than a duration or date (24h, 7d, YYYY-MM-DD)'
complete -c tg -n '__fish_tg_using_subcommand messages search thread' -l limit -x -d 'Maximum number of messages'
complete -c tg -n '__fish_tg_using_subcommand messages' -l after-id -x -d 'Include IDs above this; excludes --since'
complete -c tg -n '__fish_tg_using_subcommand messages' -l through-id -x \
    -d 'Include IDs up to this; requires --after-id'
