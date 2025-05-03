#!/usr/bin/env bash

set -e

# --- CONFIG ---
log_file="/var/log/installation.log"
start=$(date +%s)
username=$(id -un 1000)
home="/home/$username"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cur_dir=$(pwd)

# --- HELPER FUNCTIONS ---
log() {
  local message="$1"
  sudo sh -c "echo \"$(date +'%F %T') $message\" >> \"$log_file\""
}

add_to_file_if_not_in_it() {
  local string="$1"
  local path="$2"
  if ! grep -Fxq "$string" "$path" 2>/dev/null; then
    echo "$string" >> "$path"
    echo "$string added to $path"
  else
    echo "$string already exists in $path"
  fi
}

display() {
  local header_text="$1"
  if command -v figlet >/dev/null; then
    echo "--------------------------------------"
    figlet "$header_text"
    echo "--------------------------------------"
  else
    echo "===== $header_text ====="
  fi
  log "$header_text"
}

# --- PRECHECK ---
if [[ $EUID -eq 0 ]]; then
  echo "Do not run this script as root. Run it as your user." >&2
  exit 1
fi

if [[ ! -d "$home" ]]; then
  echo "Home directory $home does not exist." >&2
  exit 1
fi

sudo mkdir -p /root/.config
mkdir -p "$home/.config" "$home/desktop" "$home/downloads" "$home/pictures" "$home/music"

# --- START ---
display "Sync Time"
sudo apt install -y ntp

display "Update & Upgrade"
sudo apt update && sudo apt -y upgrade

display "Install nala"
sudo apt install -y nala figlet curl

display "Refresh mirrors"
yes | sudo nala fetch --auto

# 🛠 Add mirror refresh to root's crontab
display "Crontab setup"
cron_cmd='@reboot yes | nala fetch --auto'
(sudo crontab -l 2>/dev/null; echo "$cron_cmd") | sort -u | sudo crontab -

# -----------------------------------------
# ZSH + Oh My Zsh
# -----------------------------------------
display "Install Zsh + Oh My Zsh"

sudo nala install -y zsh fonts-powerline fonts-font-awesome zsh-syntax-highlighting

if [ ! -d "$home/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

chsh -s "$(which zsh)"

ln -sf "$cur_dir/.zshrc" "$home/.zshrc"
ln -sf "$cur_dir/.zsh" "$home/.zsh"

# -----------------------------------------
# Install Neovim from source
# -----------------------------------------
display "Install Neovim"

if ! command -v nvim >/dev/null; then
  sudo nala install -y ninja-build gettext cmake unzip curl build-essential
  git clone https://github.com/neovim/neovim /tmp/neovim
  cd /tmp/neovim
  git checkout stable
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  cd -
  rm -rf /tmp/neovim
fi

# -----------------------------------------
# Neovim Config
# -----------------------------------------
display "Configure Neovim"

if [ ! -d "$home/.config/nvim" ]; then
  pip install neovim --break-system-packages
  sudo npm install -g neovim tree-sitter-cli
  sudo apt install -y xclip
  ln -sf "$cur_dir/nvim" "$home/.config/nvim"
  sudo cp -r "$home/.config/nvim" /root/.config/nvim
  sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 50
fi

# Install lazy.nvim
mkdir -p "$home/.config/nvim/lazy"
git clone https://github.com/folke/lazy.nvim.git "$home/.config/nvim/lazy/lazy.nvim"
sudo mkdir -p /root/.config/nvim/lazy
sudo cp -r "$home/.config/nvim/lazy/lazy.nvim" /root/.config/nvim/lazy/lazy.nvim

# -----------------------------------------
# Final log + duration
# -----------------------------------------
end=$(date +%s)
runtime=$((end - start))

display "Install Complete"
echo "⏱ Script executed in $runtime seconds."
log "Installation script completed."

