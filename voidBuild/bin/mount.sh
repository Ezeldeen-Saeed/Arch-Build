#!/bin/bash

# Define the base directory for mounts
MOUNT_DIR="$HOME/drives"

# Create the base directory if it does not exist
mkdir -p "$MOUNT_DIR"

# Get a list of external drives with partitions
DRIVES=$(lsblk -l | grep -E '^sd[a-z][0-9]*' | awk '{print $1}' | sort)

# If there are no drives, exit
if [ -z "$DRIVES" ]; then
    echo "No drives found."
    exit 1
fi

# Use dmenu to select a drive with a visible limit of 10 lines
PARTITION=$(echo "$DRIVES" | dmenu -l 10 -p "Select a partition to mount or unmount:")

# Check if a partition was selected
if [ -z "$PARTITION" ]; then
    echo "No partition selected. Exiting."
    exit 1
fi

# Get the device path
DEVICE="/dev/$PARTITION"

# Get volume label, fall back to UUID if no label
LABEL=$(blkid -o value -s LABEL "$DEVICE")
if [ -z "$LABEL" ]; then
    LABEL="no_label"
fi

UUID=$(blkid -o value -s UUID "$DEVICE")
MOUNT_POINT="$MOUNT_DIR/$LABEL-$UUID"

# Check if the device is already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "Unmounting $DEVICE from $MOUNT_POINT"
    doas umount "$MOUNT_POINT"
    
    # Check if the unmount was successful
    if [ $? -eq 0 ]; then
        echo "Drive unmounted successfully"
        rmdir "$MOUNT_POINT"
        echo "Removed mount point directory $MOUNT_POINT"
    else
        echo "Failed to unmount drive"
        exit 1
    fi
else
    # Create the mount point directory if it does not exist
    mkdir -p "$MOUNT_POINT"

    # Determine the filesystem type
    FILESYSTEM_TYPE=$(blkid -o value -s TYPE "$DEVICE")

    # Fallback to vfat for FAT32 and NTFS if filesystem type not found
    if [ -z "$FILESYSTEM_TYPE" ]; then
        echo "No filesystem type detected, falling back to vfat (FAT32/ExFAT)."
        FILESYSTEM_TYPE="vfat"
    elif [ "$FILESYSTEM_TYPE" == "ntfs" ]; then
        # Use ntfs-3g driver for NTFS partitions
        FILESYSTEM_TYPE="ntfs-3g"
    fi

    # Attempt to mount the selected partition with the detected filesystem type
    echo "Mounting $DEVICE to $MOUNT_POINT with filesystem type $FILESYSTEM_TYPE"
    doas mount -t "$FILESYSTEM_TYPE" "$DEVICE" "$MOUNT_POINT"

    # Check if the mount was successful
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Drive mounted successfully at $MOUNT_POINT"
    else
        echo "Failed to mount drive"
        rmdir "$MOUNT_POINT"
        exit 1
    fi

    # Optionally, add to /etc/fstab for automount (prompt user)
    read -p "Do you want to add this drive to /etc/fstab for automount? (y/n): " answer
    if [ "$answer" == "y" ]; then
        if grep -q "$DEVICE" /etc/fstab; then
            echo "Entry already exists in /etc/fstab"
        else
            echo "Adding entry to /etc/fstab"
            echo "UUID=$UUID $MOUNT_POINT $FILESYSTEM_TYPE defaults 0 0" | doas tee -a /etc/fstab
            echo "Updated /etc/fstab"
        fi
    else
        echo "Skipping /etc/fstab update"
    fi
fi
