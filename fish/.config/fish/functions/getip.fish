function getip --description "Print and copy the public IP address"
    set -f ip (curl -fsS https://ifconfig.me/ip)
    or return

    echo $ip
    if command -q pbcopy
        echo $ip | pbcopy
    end
end
