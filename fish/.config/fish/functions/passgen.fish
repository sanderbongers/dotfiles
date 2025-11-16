if command -q op
    function passgen
        op item create --category Password --generate-password --dry-run --format json | jq -r '.fields[0].value'
    end
end
