#!/bin/bash

# Prompt user to select target platform and supported yocto branch
echo "Select target platform:"
select option in "Raspberry Pi"; do
    case $option in
        "Raspberry Pi")  platform="rpi"; break ;;
        *)               echo "Invalid option, try again." ;;
    esac
done

echo "Select Yocto branch:"
select option in "Scarthgap"; do
    case $option in
        "Scarthgap")  branch="scarthgap"; break ;;
        *)               echo "Invalid option, try again." ;;
    esac
done

echo "Platform: $platform"
echo "Branch: $branch"

# Make temporary directory relative to working directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
temp_dir="$script_dir/${platform}_temp"
mkdir -p "$temp_dir"
cd "$temp_dir" || { echo "ERROR: failed to cd into $temp_dir"; exit 1; }

echo "Working directory: $(pwd)"

# Remove all ./repo directories in search tree since repo init could use some stale version
search_dir="$(dirname "$temp_dir")"
while [ "$search_dir" != "/" ]; do
    if [ -d "$search_dir/.repo" ]; then
        echo "Removing stale .repo found in: $search_dir"
        rm -rf "$search_dir/.repo"
    fi
    search_dir="$(dirname "$search_dir")"
done

# Define manifest file based on platform and branch
manifest_file="${platform}-${branch}-manifest.xml"

# Initialize repository and fetch resources
repo init -u https://github.com/ratkost00/IoT_hub -b "$branch" -m "$manifest_file" || { echo "ERROR: repo init failed"; exit 1; }
repo sync || { echo "ERROR: repo sync failed"; exit 1; }

echo "Done. Sources are in: $temp_dir"