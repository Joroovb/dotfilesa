#!/bin/bash

# Create .themes folder
APPEARDIR=$HOME/.themes/
sudo mkdir -p $APPEARDIR

# Install latest version of Dracula GTK theme
git clone https://github.com/dracula/gtk.git
sudo mv "gtk/" "Dracula/"
sudo cp -r "Dracula/" "${HOME}/.themes/"

# Install papirus icons & folders
wget -qO- https://git.io/papirus-icon-theme-install | DESTDIR="$HOME/.icons" sh
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C black --theme Papirus-Dark

# Download and install latest version of Oh-my-bash
#### TODO CHANGE THIS INSTALL LINK TO OH MY BASH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install powerline
##### TODO GET POWERLINE THEME
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install software from pamac
pamac install lxappearance termite neovim

# Remove obsolete config files
mv -v ~/.vimrc ~/.vimrc.old
mv -v ~/.zshrc ~/.zshrc.old
mv -v ~/.bashrc ~/.bashrc/old

# Create symlink for dotfiles
# ln -s DOTFILE TARGET
ln -s ${PWD}/.bashrc ${HOME}/.bashrc
ln -s ${PWD}/.zshrc ${HOME}/.zshrc



# Fix permissions
sudo chmod u=rwx,g=rwx ~/.oh-my-zsh
sudo chmod -R u=rwx,g=rwx ~/.icons

echo Done!
