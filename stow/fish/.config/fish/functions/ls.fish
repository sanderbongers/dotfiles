function ls --description "alias ls=ls -Apv --color"
    if status is-interactive
        command ls -Apv --color $argv
    else
        command ls $argv
    end
end
