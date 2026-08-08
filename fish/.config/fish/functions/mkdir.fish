if status is-interactive
    function mkdir --description "alias mkdir=mkdir -pv"
        command mkdir -pv $argv
    end
end
