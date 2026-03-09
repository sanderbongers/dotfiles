if test -f ~/.colima/default/docker.sock
    set -gx DOCKER_HOST unix://$HOME/.colima/default/docker.sock
end
