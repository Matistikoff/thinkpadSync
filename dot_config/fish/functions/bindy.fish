function bindy --description 'Open Hyprland keybindings in Vim' --wraps vim
    vim "$HOME/.config/hypr/hyprland.lua" $argv
end
