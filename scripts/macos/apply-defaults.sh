#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
iterm2_prefs="$(cd "$script_dir/../../config/iterm2" && pwd)"
profile_file="$script_dir/../../.machine-profile"

# Sandboxed apps store preferences inside their containers (Full Disk Access needed).
container_prefs() {
    printf '%s/Library/Containers/%s/Data/Library/Preferences/%s' "$HOME" "$1" "$1"
}
coteditor_prefs="$(container_prefs com.coteditor.CotEditor)"
mail_prefs="$(container_prefs com.apple.mail)"
notes_prefs="$(container_prefs com.apple.Notes)"
safari_prefs="$(container_prefs com.apple.Safari)"
textedit_prefs="$(container_prefs com.apple.TextEdit)"

dock_add() {
    local name="$1" dir
    for dir in /System/Applications /Applications; do
        if [[ -d "$dir/$name.app" ]]; then
            dockutil --add "$dir/$name.app" --section apps --no-restart >/dev/null
            return
        fi
    done
    echo "macos/apply-defaults: could not find $name.app, skipping dock entry" >&2
}

dock_spacer() {
    dockutil --add '' --type small-spacer --section apps --no-restart >/dev/null
}

case "$(<"$profile_file")" in
    personal) chat=Messages ide="Visual Studio Code" ai=ChatGPT infra= ;;
    work) chat=Slack ide=PhpStorm ai=Claude infra=OrbStack ;;
    *)
        echo "macos/apply-defaults: $profile_file must contain 'personal' or 'work'" >&2
        exit 1
        ;;
esac

# Language and region
defaults write -g AppleLanguages -array "en-NL" "nl-NL"
defaults write -g AppleLocale -string "en_NL"

# Keyboard and input
defaults write -g AppleKeyboardUIMode -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool false

# Trackpad
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Display and screen saver
defaults -currentHost write com.apple.screensaver idleTime -int 0
sudo pmset -c displaysleep 10

# General UI
defaults write -g AppleShowAllExtensions -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g SLSMenuBarUseBlurredAppearance -bool true

# Window Manager
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Control Center
defaults -currentHost write com.apple.controlcenter Sound -int 16 # Always Show
defaults -currentHost write com.apple.controlcenter AirplayReceiverEnabled -bool false

# Dock
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.dock tilesize -int 64

dock_layout=(
    Firefox Mail "$chat" Calendar Reminders Notes Notion
    --
    iTerm "$ide" "$ai" TablePlus Bruno "Burp Suite" "$infra"
    Affinity Spotify "System Settings"
    --
)

# Dock contents
dockutil --remove all --no-restart >/dev/null
for entry in "${dock_layout[@]}"; do
    case "$entry" in
        '') ;;
        --) dock_spacer ;;
        *) dock_add "$entry" ;;
    esac
done
dockutil --add "$HOME/Downloads" --section others --view fan --display folder --sort dateadded --no-restart >/dev/null

# Finder
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # List view
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
defaults write com.apple.finder NewWindowTarget -string "PfHm" # Home
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Screenshots
defaults write com.apple.screencapture captureHDR -bool false
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture include-date -bool false
defaults write com.apple.screencapture location -string "$HOME/Downloads"
defaults write com.apple.screencapture show-thumbnail -bool false

# Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 100 # All Processes
defaults write com.apple.ActivityMonitor UpdatePeriod -int 2

# Calendar
defaults write com.apple.iCal "TimeZone support enabled" -bool true
defaults write com.apple.iCal "Show Week Numbers" -bool true
defaults write com.apple.iCal enableTravelAdvisoriesForAutomaticBehavior -bool false

# Mail
defaults write "$mail_prefs" AddLinkPreviews -bool false

# Notes
defaults write "$notes_prefs" ShouldCorrectSpellingAutomatically -bool false

# Reminders
defaults write com.apple.remindd shouldIncludeRemindersDueTodayInBadgeCount -bool false
defaults write com.apple.remindd showRemindersAsOverdue -bool true

# Safari
defaults write "$safari_prefs" AlwaysRestoreSessionAtLaunch -bool true
defaults write "$safari_prefs" AutoOpenSafeDownloads -bool false
defaults write "$safari_prefs" EnableEnhancedPrivacyInRegularBrowsing -bool true
defaults write "$safari_prefs" IncludeDevelopMenu -bool true
defaults write "$safari_prefs" ShowFullURLInSmartSearchField -bool true
defaults write "$safari_prefs" WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write "$safari_prefs" WebKitPreferences.developerExtrasEnabled -bool true
defaults write "$safari_prefs" WebKitPreferences.privateClickMeasurementEnabled -bool false
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# TextEdit
defaults write "$textedit_prefs" RichText -bool false

# iTerm2
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$iterm2_prefs"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Disable auto-updates (Homebrew manages it for these, see stow/homebrew/.homebrew/brew.env)
defaults write "$coteditor_prefs" SUEnableAutomaticChecks -bool false
defaults write com.adguard.mac.vpn SUEnableAutomaticChecks -bool false
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false
defaults write com.tinyapp.TablePlus SUEnableAutomaticChecks -bool false
defaults write dev.kdrag0n.MacVirt SUEnableAutomaticChecks -bool false
defaults write net.freemacsoft.AppCleaner SUEnableAutomaticChecks -bool false
defaults write notion.id NotionNoAutoUpdates -bool true
# Excluded here because they don't use Sparkle settings: 1Password, Bruno, PhpStorm, Telegram, and VS Code.

# Affinity: no automatic updates, but check every 30 days
defaults write com.canva.affinity AutoUpdateInterval -int 30
defaults write com.canva.affinity SUScheduledCheckInterval -int 2592000
defaults write com.canva.affinity SUEnableAutomaticChecks -bool true
defaults write com.canva.affinity SUAutomaticallyUpdate -bool false

# Telemetry opt-outs
defaults write com.googlecode.iterm2 SUSendProfileInfo -bool false
defaults write net.freemacsoft.AppCleaner SUSendProfileInfo -bool false
defaults write dev.kdrag0n.MacVirt SUSendProfileInfo -bool false
defaults write com.adguard.mac.adguard SendTelemetry -bool false
defaults write com.adguard.mac.vpn gs-send-statistics -bool false
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# Apply
killall Dock
killall Finder
chflags nohidden ~/Library

echo "macOS user defaults applied."
