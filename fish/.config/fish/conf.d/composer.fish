if command -q composer
    fish_add_path -g ~/.composer/vendor/bin

    if status is-interactive
        abbr -a ci "symfony composer install"
        abbr -a cu "symfony composer update"
    end
end
