function mkcdir --wraps mkdir --description "Create a directory and directly move into it"
    command mkdir -pv $argv
    or return

    string match -q -- '-*' $argv[-1]; or cd $argv[-1]
end
