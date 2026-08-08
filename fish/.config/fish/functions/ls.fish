if status is-interactive
    function ls --description "alias ls=ls -Apv --color"
        command ls -Apv --color $argv
    end
end
