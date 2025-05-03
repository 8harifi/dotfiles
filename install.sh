#!/bin/bash

# Exit on error
set -e

echo "🧼 Updating system and installing base packages..."
sudo apt update && sudo apt install -y \
    i3 \
    rofi \
    picom \
    feh \
    git \
    curl \
    wget \
    unzip \
    xinit \
    fonts-font-awesome \
    alacritty \
    zsh \
    ripgrep \
    fd-find \
    tar \
    build-essential \
    libfuse2  # required for some AppImages

# -----------------------------------------
# Install Neovim (latest release manually)
# -----------------------------------------
echo "📦 Installing latest Neovim..."
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz
tar -xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz
echo "✅ Neovim installed as version $NVIM_VERSION"

# -----------------------------------------
# Install Zsh + Oh My Zsh
# -----------------------------------------
echo "💻 Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

chsh -s $(which zsh)

# -----------------------------------------
# Symlink dotfiles
# -----------------------------------------
echo "🔗 Symlinking config files..."

mkdir -p ~/.config

# Shell and X session
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.xinitrc ~/.xinitrc

# App configs
ln -sf ~/.dotfiles/.config/i3 ~/.config/i3
ln -sf ~/.dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/.dotfiles/.config/alacritty ~/.config/alacritty
ln -sf ~/.dotfiles/.config/rofi ~/.config/rofi
ln -sf ~/.dotfiles/.config/picom.conf ~/.config/picom.conf

# -----------------------------------------
# Setup lazy.nvim plugin manager
# -----------------------------------------
echo "🚀 Installing lazy.nvim..."
mkdir -p ~/.config/nvim/lazy
git clone https://github.com/folke/lazy.nvim.git ~/.config/nvim/lazy/lazy.nvim

echo "🎉 Setup complete!"
echo "👉 Launch Neovim with 'nvim' and run :Lazy to check plugins."
echo "👉 Start i3 with 'startx'"

