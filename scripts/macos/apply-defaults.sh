#!/usr/bin/env bash

set -euo pipefail

dock_add() {
    local name="$1" dir
    for dir in /System/Applications /System/Applications/Utilities /Applications; do
        if [[ -d "$dir/$name.app" ]]; then
            dockutil --add "$dir/$name.app" --no-restart >/dev/null
            return
        fi
    done
    echo "macos/apply-defaults: could not find $name.app, skipping dock entry" >&2
}

dock_add_folder() {
    local path="$1"
    if [[ -d "$path" ]]; then
        dockutil --add "$path" --view grid --display stack --no-restart >/dev/null
    else
        echo "macos/apply-defaults: $path does not exist, skipping dock entry" >&2
    fi
}

# Keyboard and input
# defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true
# defaults write -g AppleKeyboardUIMode -int 3
# defaults write -g InitialKeyRepeat -int 25
# defaults write -g KeyRepeat -int 2
# defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
# defaults write -g com.apple.trackpad.scaling -float 1.5
# defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Trackpad gestures (captured from ~/Library/Preferences/ByHost/.GlobalPreferences.<UUID>.plist)
# defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -int 1
# defaults -currentHost write -g com.apple.trackpad.scrollBehavior -int 2
# defaults -currentHost write -g com.apple.trackpad.momentumScroll -int 1
# defaults -currentHost write -g com.apple.trackpad.pinchGesture -int 1
# defaults -currentHost write -g com.apple.trackpad.rotateGesture -int 1
# defaults -currentHost write -g com.apple.trackpad.twoFingerDoubleTapGesture -int 1
# defaults -currentHost write -g com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.threeFingerDragGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.threeFingerHorizSwipeGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.threeFingerTapGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.threeFingerVertSwipeGesture -int 2
# defaults -currentHost write -g com.apple.trackpad.fourFingerHorizSwipeGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.fourFingerPinchSwipeGesture -int 0
# defaults -currentHost write -g com.apple.trackpad.fourFingerVertSwipeGesture -int 2
# defaults -currentHost write -g com.apple.trackpad.fiveFingerPinchSwipeGesture -int 0

# General UI
# defaults write -g AppleShowAllExtensions -bool true
# defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
# defaults write -g PMPrintingExpandedStateForPrint2 -bool true
# defaults write com.apple.helpviewer HVIncludesKBSearches -bool false
# defaults write com.apple.LaunchServices LSQuarantine -bool false
# defaults write com.apple.appleseed.FeedbackAssistant Autogather -bool false
# defaults write com.apple.TextEdit RichText -bool false
# defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Dock
# defaults write com.apple.dock autohide -bool false
# defaults write com.apple.dock autohide-delay -float 0.2
# defaults write com.apple.dock autohide-time-modifier -float 0.33
# defaults write com.apple.dock magnification -bool false
# defaults write com.apple.dock show-recents -bool false
# defaults write com.apple.dock size-immutable -bool true
# defaults write com.apple.dock tilesize -int 48

# Finder
# defaults write com.apple.finder _FXSortFoldersFirst -bool true
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# defaults write com.apple.finder FXRemoveOldTrashItems -bool true
# defaults write com.apple.finder NewWindowTargetPath "file://$HOME/Downloads/"
# defaults write com.apple.finder QuitMenuItem -bool true
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
# defaults write com.apple.finder ShowPathbar -bool true
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Screenshots
# defaults write com.apple.screencapture disable-shadow -bool true
# defaults write com.apple.screencapture include-date -bool false
# defaults write com.apple.screencapture location ~/Downloads
# defaults write com.apple.screencapture show-thumbnail -bool false

# Dock contents (dockutil)
# dockutil --remove all --no-restart >/dev/null
# for app in Calculator Safari Messages Mail Maps Photos FaceTime Phone Calendar Contacts Reminders Notes \
#     TV Music Games "App Store" "System Settings"; do
#     dock_add "$app"
# done
# dockutil --add '' --type spacer --section apps --no-restart >/dev/null
# dock_add_folder "$HOME/Downloads"
# dock_add_folder "$HOME/bin"

# Apply
# killall Dock
# killall Finder
# chflags nohidden ~/Library
# sudo pmset -a displaysleep 60 ttyskeepawake 1
