if command -q php
    abbr -a bc "php bin/console"

    if command -q brew
        abbr --command={php7.4,php8.1,php8.2} composer "(brew --prefix composer)/bin/composer"
        abbr --command={php7.4,php8.1,php8.2} wp "(brew --prefix wp-cli)/bin/wp"
    end
end
