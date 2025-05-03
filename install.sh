#!/bin/bash

set -e

USERNAME=$(whoami)

echo "🚀 Starting Debian post-install bootstrap..."

# -----------------------------------------
# Function to run root commands via sudo or su
# -----------------------------------------
run_as_root() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    su -c "$*"
  fi
}

# -----------------------------------------
# 1. Install sudo if missing
# -----------------------------------------
if ! command -v sudo >/dev/null 2>&1; then
  echo "🛠️  sudo not found. Installing using su..."
  su -c "apt update && apt install -y sudo"
fi

# -----------------------------------------
# 2. Add user to sudo group if not already
# -----------------------------------------
if ! groups "$USERNAME" | grep -qw sudo; then
  echo "🛡️  Adding $USERNAME to sudo group..."
  run_as_root usermod -aG sudo "$USERNAME"
  echo "➡️  Log out and log back in for sudo access to take effect."
fi

# -----------------------------------------
# 3. Update and install essential packages
# -----------------------------------------
echo "📦 Installing essential packages..."
run_as_root apt update && run_as_root apt install -y \
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
run_as_root mv nvim-linux64 /opt/nvim
run_as_root ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
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
# 9. Locales and firewall
# -----------------------------------------
echo "🌐 Setting locales and enabling firewall..."
run_as_root locale-gen en_US.UTF-8
run_as_root ufw enable

echo "🎉 All done!"
echo "🔁 Log out and back in if you were just added to the sudo group."
echo "👉 Run 'startx' to launch i3 or 'nvim' to edit your config!"

