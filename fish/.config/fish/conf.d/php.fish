if command -q php
    abbr -a "b/c" -p anywhere "bin/console"

    if command -q brew
        abbr --command={php7.4,php8.1,php8.2} composer "(brew --prefix)/bin/composer"
        abbr --command={php7.4,php8.1,php8.2} wp "(brew --prefix)/bin/wp"
    end
end
