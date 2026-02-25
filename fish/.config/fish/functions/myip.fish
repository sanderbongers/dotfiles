function myip
    set ip (curl -s https://ifconfig.me)
    echo $ip
    if command -q pbcopy
        echo $ip | pbcopy
    end
end
