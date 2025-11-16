#!/usr/bin/env bash

set -euo pipefail

if ! grep -qs pam_tid.so /etc/pam.d/sudo_local; then
    echo "Enabling Touch ID for sudo..."
    if [[ ! -f /etc/pam.d/sudo_local ]]; then
        sudo install -m 444 -o root -g wheel /dev/null /etc/pam.d/sudo_local
    fi
    echo "auth  sufficient  pam_tid.so" | sudo tee -a /etc/pam.d/sudo_local
fi

if [[ ! -x $(command -v brew) ]]; then
    echo "Installing Homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ ! -x $(command -v fish) ]]; then
    echo "Installing Fish..."
    brew install fish
fi

if [[ $(basename "$SHELL") != "fish" ]]; then
    echo "Setting Fish as default shell..."
    grep -q "$(which fish)" /etc/shells || which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
    SHELL_CHANGED=true
fi

if [ -d ~/.config/fish ] && [ ! -L ~/.config/fish ]; then
    echo "Removing default Fish configuration..."
    rm -rf ~/.config/fish
fi

echo "Stowing dotfiles..."
[[ -x $(command -v stow) ]] || brew install stow
make link

echo "Installing Homebrew packages..."
make bundle-install

echo "Rebuilding bat cache..."
bat cache --build

echo "Setting macOS user defaults..."
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true
defaults write -g AppleKeyboardUIMode -int 3
defaults write -g AppleShowAllExtensions -bool true
defaults write -g com.apple.trackpad.scaling -float 1.5
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 2
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock autohide-delay -float 0.2
defaults write com.apple.dock autohide-time-modifier -float 0.33
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock size-immutable -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder NewWindowTargetPath "file://$HOME/Downloads/"
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.helpviewer HVIncludesKBSearches -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture include-date -bool false
defaults write com.apple.screencapture location ~/Downloads
defaults write com.apple.screencapture show-thumbnail -bool false
defaults write com.apple.TextEdit RichText -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
killall Dock
killall Finder
chflags nohidden ~/Library
sudo pmset -a displaysleep 60 ttyskeepawake 1

[[ $SHELL_CHANGED ]] && echo "Changed default shell to Fish, restart terminal to apply changes."
