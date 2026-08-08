function _agent_skills_link --description "Unify proprietary skills directories to ~/.agents/skills"
    set -l skills_dir ~/.agents/skills
    set -l destinations ~/.claude/skills ~/.cursor/skills

    if not test -d $skills_dir
        return 0
    end

    for destination in $destinations
        set -l parent (dirname $destination)
        if test -d $parent
            if test -L $destination; or test -d $destination
                command rm -r $destination
            end
            ln -sfn $skills_dir $destination
        end
    end
end
