if test -f ~/.orbstack/run/docker.sock
    source ~/.orbstack/shell/init2.fish 2>/dev/null

    set -gx DOCKER_HOST unix://$HOME/.orbstack/run/docker.sock
end
