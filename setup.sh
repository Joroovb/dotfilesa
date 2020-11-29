#!/bin/bash

# Install software from pamac
pamac install lxappearance autotiling termite neovim nodejs sublime-text-3 nerd-fonts-complete feh polybar rofi dunst yay playerctl gufw lightdm-gtk-greeter-settings fish lolcat figlet picom-ibhagwan-git networkmanager-dmenu

# Create .themes folder
APPEARDIR=$HOME/.themes/
sudo mkdir -p $APPEARDIR

# Install latest version of Dracula GTK theme
git clone https://github.com/dracula/gtk.git
sudo mv "gtk/" "Dracula/"
sudo cp -r "Dracula/" "${HOME}/.themes/"
rm -r "Dracula/" 

# Install papirus icons & folders
wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.icons" sh
sudo chmod -R u=rwx,g=rwx ~/.icons
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C bluegrey --theme Papirus-Dark

# Install the latest version  of Spaceship
curl -fsSL https://starship.rs/install.sh | bash

# Create symlink for vimrc
mv -v ~/.vimrc ~/.vimrc.old
ln -s ${PWD}/.vimrc ${HOME}/.vimrc

# Symlink termite config
rm -r ${HOME}/.config/termite
ln -s ${PWD}/.config/termite ${HOME}/.config/termite

# Symlink i3 config
rm -r ${HOME}/.config/i3
ln -s ${PWD}/.config/i3 ${HOME}/.config/i3

# Symlink dunst config
rm -r ${HOME}/.config/dunst
ln -s ${PWD}/.config/dunst ${HOME}/.config/dunst

# Symlink polybar config
rm -r ${HOME}/.config/polybar
ln -s ${PWD}/.config/polybar ${HOME}/.config/polybar

# Symlink rofi config
rm -r ${HOME}/.config/rofi
ln -s ${PWD}/.config/rofi ${HOME}/.config/rofi

# Symlink picom config
rm -r ${HOME}/.config/picom
ln -s ${PWD}/.config/picom ${HOME}/.config/picom

# Symlink fish config
rm -r ${HOME}/.config/fish
ln -s ${PWD}/.config/fish ${HOME}/.config/fish

# Symlink nvim config
rm -r ${HOME}/.config/nvim
ln -s ${PWD}/.config/nvim ${HOME}/.config/nvim

# Create symlink for wallpapers
ln -s ${PWD}/Walls ${HOME}/Walls
ln -s ${PWD}/Alerts ${HOME}/Alerts

# TODO COPY OVER FIGLET FONT

echo Done!
