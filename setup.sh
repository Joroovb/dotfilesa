#!/bin/bash

# Install software from pamac
pamac install lxappearance termite neovim nodejs atom nerd-fonts-complete feh polybar rofi playerctl

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

# Download and install latest version of Oh-my-bash
#### TODO CHANGE THIS INSTALL LINK TO OH MY BASH
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
sudo chmod u=rwx,g=rwx ~/.oh-my-bash

# Remove obsolete config files
mv -v ~/.vimrc ~/.vimrc.old
mv -v ~/.bashrc ~/.bashrc/old

# Create symlink for dotfiles
# ln -s DOTFILE TARGET
ln -s ${PWD}/.bashrc ${HOME}/.bashrc
ln -s ${PWD}/.vimrc ${HOME}/.vimrc
ln -s ${PWD}/.config/termite/config ${HOME}/.config/termite/config
ln -s ${PWD}/.config/i3/config ${HOME}/.config/i3/config

# Create symlink for wallpapers
ln -s ${PWD}/Walls ${HOME}/Walls
ln -s ${PWD}/Alerts ${HOME}/Alerts

# Fix permissions
sudo chmod -R u=rwx,g=rwx ~/.icons

echo Done!
