# https://github.com/BurntSushi/ripgrep

set -gx RIPGREP_CONFIG_PATH $HOME/.ripgreprc

# Workaround to use environment variable
alias rg="rg --ignore-file=$HOME/.rgignore"
