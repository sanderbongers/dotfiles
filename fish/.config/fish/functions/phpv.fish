function phpv --description "Get the PHP version from composer.json"
    test -f composer.json; and jq -r '.require.php' composer.json; or return 1
end
