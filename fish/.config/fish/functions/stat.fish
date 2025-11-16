function stat --description "alias stat=stat -x (if available)"
    command stat -x $argv 2>/dev/null; or command stat $argv
end
