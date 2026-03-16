if command -q uv
    set -gx UV_PYTHON_PREFERENCE only-system

    if not test -d ~/.local/venvs/tools
        uv venv ~/.local/venvs/tools
    end

    fish_add_path -g ~/.local/venvs/tools/bin
end
