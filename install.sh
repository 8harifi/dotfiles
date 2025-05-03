#!/bin/bash

set -e

USERNAME=$(whoami)

echo "🚀 Starting Debian post-install bootstrap..."

# -----------------------------------------
# 1. Make sure sudo is installed
# -----------------------------------------
if ! command -v sudo >/dev/null 2>&1; then
  su -c "apt update && apt install -y sudo"
fi

# -----------------------------------------
# 2. Add current user to sudo group
# -----------------------------------------
if groups $USERNAME | grep -qv '\bsudo\b'; then
  echo "🛡️  Adding $USERNAME to sudo group..."
  sudo usermod -aG sudo $USERNAME
  echo "➡️  You must log out and log back in for sudo access to take effect."
fi

# -----------------------------------------
# 3. Update system and install essentials
# -----------------------------------------
echo "📦 Installing essential packages..."
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
    xclip \
    ripgrep \
    fd-find \
    build-essential \
    libfuse2 \
    htop \
    ufw \
    locales

# -----------------------------------------
# 4. Configure PATH additions in .zshrc
# -----------------------------------------
echo "🔧 Ensuring common bin dirs are in PATH..."
cat << 'EOF' >> ~/.zshrc

# Custom PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
EOF

# -----------------------------------------
# 5. Install Oh My Zsh
# -----------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "💻 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
chsh -s $(which zsh)

# -----------------------------------------
# 6. Install Neovim (latest stable manually)
# -----------------------------------------
echo "📥 Installing latest Neovim..."
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz
tar -xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz
echo "✅ Neovim installed: $(nvim --version | head -n1)"

# -----------------------------------------
# 7. Set up lazy.nvim
# -----------------------------------------
echo "🚀 Setting up lazy.nvim..."
mkdir -p ~/.config/nvim/lazy
git clone https://github.com/folke/lazy.nvim.git ~/.config/nvim/lazy/lazy.nvim

# -----------------------------------------
# 8. Symlink dotfiles
# -----------------------------------------
echo "🔗 Symlinking dotfiles..."
mkdir -p ~/.config

ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.xinitrc ~/.xinitrc

ln -sf ~/.dotfiles/.config/i3 ~/.config/i3
ln -sf ~/.dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/.dotfiles/.config/alacritty ~/.config/alacritty
ln -sf ~/.dotfiles/.config/rofi ~/.config/rofi
ln -sf ~/.dotfiles/.config/picom.conf ~/.config/picom.conf

# -----------------------------------------
# 9. Locale and firewall setup (optional)
# -----------------------------------------
echo "🌐 Setting locales and enabling firewall..."
sudo locale-gen en_US.UTF-8
sudo ufw enable

echo "🎉 All done! You may want to log out and log back in to activate group changes."
echo "👉 Run 'startx' to launch i3 or 'nvim' to start editing."

