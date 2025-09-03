#!/usr/bin/env bash

source "./usr/lib/debian-nvidia-installer/packages.sh"

echo "Verifying script dependencies..."
depends_line=$(grep -E '^Depends:' "./DEBIAN/control" | head -n1)
depends_list=${depends_line#Depends:}
depends_list=$(echo "$depends_list" | tr -d ' ')
depends_list=$(echo "$depends_list" | tr ',' ' ')

for pkg in $depends_list; do
    if ! packages::is_installed "$pkg"; then
        echo "Missing dependency: $pkg"
        exit 1
    fi
done

echo "All dependecies are OK!"

echo "Running script..."
custom_env_vars="env DEVENV=1"

if packages::is_installed "sudo"; then
    exec gnome-terminal --title="Terminal" -- bash -c "sudo $custom_env_vars ./usr/bin/debian-nvidia-installer; exec bash"
else
    exec gnome-terminal --title="Terminal" -- bash -c "$custom_env_vars ./usr/bin/debian-nvidia-installer; exec bash"
fi