#!/bin/bash

# Install software from pamac
pamac install lxappearance autotiling termite neovim nodejs sublime-text-3 nerd-fonts-complete feh polybar rofi playerctl gufw lightdm-gtk-greeter-settings fish lolcat figlet

# Create .themes folder
APPEARDIR=$HOME/.themes/
sudo mkdir -p $APPEARDIR

# Install latest version of Dracula GTK theme
git clone https://github.com/dracula/gtk.git
sudo mv "gtk/" "Dracula/"
sudo cp -r "Dracula/" "${HOME}/.themes/"

# Install papirus icons & folders
wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.icons" sh
sudo chmod -R u=rwx,g=rwx ~/.icons
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C black --theme Papirus-Dark

# Remove obsolete config files
mv -v ~/.vimrc ~/.vimrc.old
mv -v ~/.bashrc ~/.bashrc/old

# Install the latest version  of Spaceship
curl -fsSL https://starship.rs/install.sh | bash

# TODO SETUP FISH FILES

# Create symlink for dotfiles
ln -s ${PWD}/.bashrc ${HOME}/.bashrc
ln -s ${PWD}/.vimrc ${HOME}/.vimrc

# Symlink termite config
mkdir ~/.config/termite
ln -s ${PWD}/.config/termite/config ${HOME}/.config/termite/config

# Symlink i3 config
mkdir ~/.config/i3
ln -s ${PWD}/.config/i3/config ${HOME}/.config/i3/config
ln -s ${PWD}/.config/dunst/ ${HOME}/.config/dunst
ln -s ${PWD}/.config/polybar ${HOME}/.config/polybar
ln -s ${PWD}/.config/rofi ${HOME}/.config/rofi

# Create symlink for wallpapers
ln -s ${PWD}/Walls ${HOME}/Walls
ln -s ${PWD}/Alerts ${HOME}/Alerts

# TODO COPY OVER FIGLET FONT

echo Done!
