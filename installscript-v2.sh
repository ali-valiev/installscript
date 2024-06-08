#!/bin/bash

dwm_autostart="false"
echo "WARNING: dwm autostar is set to $dwm_autostart"

# Get the username from the environment variable
username="$USER"
home_dir="/home/$username"

# Create the .config directory
mkdir -p "$home_dir/.config/"

# Define configuration directories
config_dir="$home_dir/.config"
dotfiles_dir="$config_dir/dotfiles"

github="https://github.com/ali-valiev"

# Set the type of distribution: 1 for Arch, 2 for Debian
type=1


# Check the distribution type and install dependencies accordingly
if [ "$type" -eq 1 ]; then
    echo "Installing dependencies for Arch"
    sudo pacman -S --needed git base-devel \
			xorg libx11 libxft libxinerama freetype2 fontconfig \
      feh neovim alacritty firefox curl wget unzip \
			pipewire pipewire-pulse pavucontrol \
			unclutter dunst openssh \
			ttf-martian-mono-nerd otf-firamono-nerd
elif [ "$type" -eq 2 ]; then
    echo "Debian is not supported for now"
    echo "Have to check package names..."
else
    echo "ERROR: Set distro type properly"
    echo "Exiting..."
    exit 1
fi


# Array of directories to move
directories=(
    "$dotfiles_dir/"
    "$config_dir/nvim/"
    "$config_dir/suckless/"
    "$config_dir/alacritty/"
    "$config_dir/dunst/"
)

# Move directories to backup locations
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        mv "$dir" "${dir%/}-old/"
    fi
done

# Move .bashrc if it exists
if [ -f "$home_dir/.bashrc" ]; then
    mv "$home_dir/.bashrc" "$home_dir/.bashrc-old"
fi


git clone "$github/dotfiles" "$dotfiles_dir"
git clone "$github/nvim"		 "$config_dir/nvim/"
git clone "$github/suckless" "$config_dir/suckless/"


cp "$dotfiles_dir/bashrc"	"$home_dir/.bashrc"
cp "$dotfiles_dir/xinitc" "$home_dir/.xinitrc"

cp -r "$dotfiles_dir/alacritty/" "$config_dir/alacritty/"
cp -r "$dotfiles_dir/dunst/"		 "$config_dir/dunst/"

cd "$config_dir/suckless/"
bash build-all.sh

if [ "$dwm_autostart" == "true"]; then
	echo '
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
' >> ~/.bash_profile
fi
