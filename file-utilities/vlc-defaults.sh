#!/bin/zsh
# Name: VLC Defaults
# Purpose: Set VLC settings for screenshots to its optimal values 
# Author: @ks1v, ChatGPT-4 assisted
# Version: 0.1

# Get current username
current_user="$USER"

# VLC settings file path
vlc_config_file="/Users/$current_user/Library/Preferences/org.videolan.vlc/vlcrc"

# Define the settings and their expected values
declare -A settings_defaults
settings_defaults[snapshot-path]="/Users/$current_user/screenshots"
settings_defaults[snapshot-prefix]='\$N_\$T'  # Escape $ characters
settings_defaults[snapshot-format]="png"

# Function to update a setting in the vlcrc file
update_setting() {
    local setting=$1
    local value=$2
    sed -i '' "s#^${setting}=.*#${setting}=${value}#" "$vlc_config_file"
}

# Check each setting and process accordingly
for setting in "${(@k)settings_defaults}"; do
    expected_value=${settings_defaults[$setting]}
    current_value=$(grep "^${setting}=" "$vlc_config_file" | cut -d'=' -f2)

    # Check if the current value is different from the expected value
    if [[ "$current_value" != "$expected_value" ]]; then
        echo "The setting '$setting' has a different value ($current_value). Expected: $expected_value"
        read "response?Do you want to change it to the expected value? (yes/no): "
        
        if [[ "$response" == "yes" ]]; then
            update_setting "$setting" "$expected_value"
            echo "Updated '$setting' to its expected value."
        else
            echo "No changes made to '$setting'."
        fi
    fi
done
