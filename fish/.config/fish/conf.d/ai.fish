for agent in claude codex gemini
    if command -q $agent
        mkdir -p ~/.agents/skills ~/.$agent/ >/dev/null
        ln -sf ~/.agents/skills ~/.$agent/skills
    end
end
