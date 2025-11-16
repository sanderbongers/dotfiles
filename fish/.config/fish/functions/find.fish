function find --description "Walk a file hierarchy, excluding macOS VFS"
    set -l vfs_dir /System/Volumes/Data

    command find $argv -not -path $vfs_dir
end
