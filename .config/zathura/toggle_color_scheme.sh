#!/bin/sh

CONFIG_FILE="$HOME/.config/zathura/zathurarc"
BACKUP_FILE="$HOME/.config/zathura/zathurarc.bak"

# Check if Gruvbox Dark is currently set
if grep -q "recolor-darkcolor '#fbf1c7'" "$CONFIG_FILE"; then
    # Restore default configuration
    cp "$BACKUP_FILE" "$CONFIG_FILE"
else
    # Backup current configuration
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    
    # Set Gruvbox Dark colors
    {
        echo "set recolor true"
        echo "set recolor-lightcolor '#282828'"
        echo "set recolor-darkcolor '#fbf1c7'"
    } > "$CONFIG_FILE"
fi

# Reload Zathura to apply changes
pkill -USR1 zathura
