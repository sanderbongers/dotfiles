function mkdir --description "alias mkdir=mkdir -pv"
    if status is-interactive
        command mkdir -pv $argv
    else
        command mkdir $argv
    end
end
