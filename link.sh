#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit 1

BACKUP_SUFFIX=".bpk.$(date +%Y%m%d-%H%M%S)"

replace() {
    local newFile oldFile
    newFile="$(realpath "$1")"
    oldFile="${2%/}"

    if [ -L "$oldFile" ] && [ "$(realpath "$oldFile")" = "$newFile" ]; then
        return 0
    fi

    if [ -e "$oldFile" ] || [ -L "$oldFile" ]; then
        mv -- "$oldFile" "$oldFile$BACKUP_SUFFIX"
        echo "$oldFile: backed up to $oldFile$BACKUP_SUFFIX"
    fi

    mkdir -p "$(dirname "$oldFile")"
    ln -s "$newFile" "$oldFile"
    echo "$oldFile: linked"
}

add_myrc() {
    local rcfile="$1"

    [ -f "$rcfile" ] || return 0

    if grep -qxF "$MYRC" "$rcfile"; then
        echo "$rcfile: already sourced"
        return 0
    fi

    printf '\n%s\n' "$MYRC" >> "$rcfile"
    echo "$rcfile: line added"
}
# I hereby spread my asscheeks and offer myself to the Claude Gods for writing all the functions in this file, thank you! Please don't slime my ass on O-block when you take over the world.


# My RC
MYRC='source "$HOME/.mydotfiles/myrc"'
add_myrc "$HOME/.bashrc"
add_myrc "$HOME/.zshrc"

# Fastfetch
replace "./fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
# Hyfetch
replace "./hyfetch/hyfetch.json" "$HOME/.config/hyfetch.json"
# Git
replace "./.gitconfig" "$HOME/.gitconfig"
# Vencord settings for Flatpak Discord
replace "./vencord/settings.json" "$HOME/.var/app/com.discordapp.Discord/config/Vencord/settings/settings.json"
replace "./vencord/quickCss.css" "$HOME/.var/app/com.discordapp.Discord/config/Vencord/settings/quickCss.css"
# Flatpak cancer
flatpak override --user --filesystem="$HOME/.mydotfiles" com.discordapp.Discord

# Plasma (optional)
read -r -p "Apply Plasma config? This restarts plasmashell. [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then

    # Quit Plasma before config change
    if pgrep -x plasmashell >/dev/null; then
        kquitapp6 plasmashell
        while pgrep -x plasmashell >/dev/null; do sleep 0.2; done
    fi

    # Plasma panel and widget layout
    replace "./plasma/plasma-org.kde.plasma.desktop-appletsrc" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    replace "./plasma/plasmashellrc" "$HOME/.config/plasmashellrc"
    # Installed Plasma widgets (whole dir)
    replace "./plasma/plasmoids" "$HOME/.local/share/plasma/plasmoids"
    # Shortcuts
    replace "./plasma/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc"
    # Keyboard layout
    replace "./plasma/kxkbrc" "$HOME/.config/kxkbrc"

    # Start Plasma after config change
    kstart plasmashell &>/dev/null &

else
    echo "Skipping Plasma."
fi

echo "You don't have to but it won't be bad to restart your shit now :)"
