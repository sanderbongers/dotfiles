function getip
    set ip (curl -s https://ifconfig.me)
    echo $ip
    command -q pbcopy; and echo $ip | pbcopy
end
