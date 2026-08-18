if command -q symfony; and command -q wp
    function wp --description "Run wp-cli under the correct PHP version"
        set -l php_bin (string trim (symfony php -r "echo PHP_BINARY;" 2>/dev/null))
        if test -n "$php_bin"
            $php_bin (command -v wp) $argv
        else
            command wp $argv
        end
    end
end
