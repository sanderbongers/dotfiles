if command -q bun
    set -gx BUN_INSTALL ~/.bun
    fish_add_path -g $BUN_INSTALL/bin
end
