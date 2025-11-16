function prompt_login --description "Display username for the prompt"
    set -l prompt_host ""

    if not set -q fish_prompt_show_host; or not contains -- $fish_prompt_show_host no false 0
        set prompt_host @ (set_color $fish_color_host_remote) (prompt_hostname) (set_color normal)
    end

    echo -n -s (set_color $fish_color_user) (whoami) (set_color normal) $prompt_host
end
