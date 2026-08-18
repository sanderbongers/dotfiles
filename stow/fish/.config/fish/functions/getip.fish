function getip --description "Get my public IP address and copy it"
    argparse --strict-longopts --max-args=0 a/all -- $argv
    or return

    set -f endpoint ip
    if set -q _flag_all
        set endpoint all
    end

    set -f output (curl -fsS https://ifconfig.me/$endpoint)
    or return

    set -f ip $output
    if set -q _flag_all
        set ip (string match --regex --groups-only '^ip_addr: (.+)$' -- $output)
        or return
    end

    printf '%s\n' $output
    if command -q pbcopy
        printf '%s\n' $ip | pbcopy
    end
end
