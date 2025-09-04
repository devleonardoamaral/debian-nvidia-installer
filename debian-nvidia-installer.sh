#!/usr/bin/env bash

source "./usr/lib/debian-nvidia-installer/packages.sh"

echo "Verifying script dependencies..."
depends_line=$(grep -E '^Depends:' "./DEBIAN/control" | head -n1)
depends_list=${depends_line#Depends:}
depends_list=$(echo "$depends_list" | tr -d ' ')
depends_list=$(echo "$depends_list" | tr ',' ' ')
depends_list=($depends_list)

percent=0
current_pkg=0
max_pkg=${#depends_list[@]}
for pkg in "${depends_list[@]}"; do
    printf "%3s%% | Verifying dependency: %s\n" "$percent" "$pkg"
    if ! packages::is_installed "$pkg"; then
        echo "Missing dependency: $pkg"
        exit 1
    fi
    ((current_pkg++))
    percent=$(( current_pkg * 100 / max_pkg ))
done

 printf "%3s%% | All dependecies are OK!\n" "$percent"

echo "Executing tests..."

if ! ./tests/start_test.sh; then
    echo "Test(s) failed!"
    exit 1
fi

echo "Running script..."
custom_env_vars="env DEVENV=1"

if packages::is_installed "sudo"; then
    exec gnome-terminal --title="Terminal" -- bash -c "sudo $custom_env_vars ./usr/bin/debian-nvidia-installer; exec bash"
else
    exec gnome-terminal --title="Terminal" -- bash -c "$custom_env_vars ./usr/bin/debian-nvidia-installer; exec bash"
fi