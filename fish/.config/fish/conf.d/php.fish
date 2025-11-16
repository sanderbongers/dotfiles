if command -q php
    abbr --add bc "php bin/console"
end

if command -q brew
    abbr --command={php7.4,php8.1,php8.2} composer "(brew --prefix composer)/bin"
    abbr --command={php7.4,php8.1,php8.2} wp "(brew --prefix wp-cli)/bin"
end
