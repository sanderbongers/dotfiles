abbr -a d "cd ~/Downloads"
abbr -a p "cd ~/Projects"
abbr -a dotdot --regex '^\.\.+$' --function _multicd
abbr -a phpv "jq -r '.require.php' composer.json"
