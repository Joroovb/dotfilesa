#!/bin/bash

comment() {
    echo ">> $(tput setaf 2) $@$(tput sgr0)" >&2
}

fail() {
    echo "$(tput bold; tput setaf 5)$@$(tput sgr0)" >&2
}

run() {
    echo "# $(tput setaf 6)$@$(tput sgr0)" >&2
    "$@"
    code=$?
    if (( code > 0 ))
    then
        fail "The following command executed with error $code:"
        fail "$@"
        exit $code
    fi
}

### SETUP ###

# Install Neovim
sudo pacman -S \
    git \
    neovim 

# Set Time Zone
comment "Set correct time zone and set hardware clock accordingly"
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc

# Set Locale
comment "Set default locales and generate locales"
run echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
run echo "nl_NL.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

comment "Set default language to American English"
run echo LANG=en_US.UTF-8 >> /etc/locale.conf
comment "Set time format to display as 24:00"
run echo LC_TIME=nl_NL.UTF-8 >> /etc/locale.conf

# Set hostname
echo -n "What should this computer be called? "
read HOSTNAME
run echo "$HOSTNAME" > /etc/hostname

run cp -f ${PWD}/hosts /etc/hosts
run echo -e "\n127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts

# Setup root Password
comment "Set root password"
passwd

# Setup User
comment "Create user and add to relevant group"
echo -n "What is your username? "
read USERNAME
run useradd -m -g users -G wheel,audio,video,optical,storage -s "$(which fish)" $USERNAME

comment "Set password of new user"
run passwd $USERNAME

comment "Enable sudo access for group wheel"
run echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/sudo-for-wheel-group

### INSTALL GRUB ###
comment "Install bootloader"
sudo pacman -S \
    dosfstools \
    efibootmgr \
    grub \
    m-tools \
    os-prober

comment "Making boot folder at /boot/EFI"
mkdir /boot/efi

lsblk
comment "What is your boot partition?"
read BOOTPART
mount /dev/$BOOTPART /boot/EFI

run grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck
run grub-mkconfig -o /boot/grub/grub.cfg

# Install Pacman Software
sudo pacman -Syu
sudo pacman -S \
    bat \
    calcurse \
    curl \
    dmenu \
    dunst \
    fd \
    feh \
    fish \
    fzf \
    i3-gaps \
    lxappearance \
    networkmanager \
    networkmanager-dmenu \
    openssh \
    playerctl \
    polybar \
    rofi \
    termite \
    ufw \
    wget \
    wireless_tools \
    zathura 

# Install yay.
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install AUR software
yay -S \
    autotiling \
    #bitwarden-cli\
    lf \
    #ncspot \
    nerd-fonts-fira-code \
    #picom-ibhagwan-git \
    pistol-git 

### maybe pile ###
# xcape

# Configure ufw.
sudo ufw default deny incoming
sudo ufw default allow outgoing

### THEMING ###

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

# Symlink lf config
rm -r ${HOME}/.config/lf
ln -s ${PWD}/.config/lf ${HOME}/.config/lf

# Symlink qutebrowser config
rm -r ${HOME}/.config/qutebrowser
ln -s ${PWD}/.config/qutebrowser ${HOME}/.config/qutebrowser

# Create symlink for wallpapers and alerts
# Wallpapers from Wallhaven
ln -s ${PWD}/Walls ${HOME}/Walls
ln -s ${PWD}/Alerts ${HOME}/Alerts

# Symlink zathura config
rm -r ${HOME}/.config/zathura
ln -s ${PWD}/.config/zathura ${HOME}/.config/zathura

# Symlink starship config
ln -s ${PWD}/.config/starship.toml ${HOME}/.config/starship.toml

### Enable Services ###
run systemctl enable networkmanager

echo Done!
