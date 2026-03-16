if command -q uv
    set -gx UV_PYTHON_PREFERENCE only-system

    fish_add_path -g ~/.local/venvs/tools/bin
end
