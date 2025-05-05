#!/usr/bin/env bash

# Enable exit on error
set -e


run_step() {
  local name="$1"
  shift

  # If START_FROM is defined, skip steps until we reach it
  if [[ -n "$START_FROM" && "$START_FROM" != "$name" && "$SKIP" != false ]]; then
    echo "⏩ Skipping $name"
    return
  fi

  SKIP=false
  CURRENT_STEP="$name"

  echo -e "\n🟢 Starting: $name"
  "$@"
}


# Function to log messages
log() {
  local message="$1"
  sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

confirm() {
  while true; do
    read -rp "Do you want to proceed? [Yes/No/Cancel] " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      [Cc]*) exit ;;
      *) echo "Please answer YES, NO, or CANCEL." ;;
    esac
  done
}

# Example usage of the confirm function
# if confirm; then
#     echo "User chose YES. Executing the operation..."
#     # Place your code here to execute when user confirms
# else
#     echo "User chose NO. Aborting the operation..."
#     # Place your code here to execute when user denies
# fi

# Function to add a line to a file if it doesn't exist
add_to_file_if_not_in_it() {
  local string="$1"
  local path="$2"

  if ! grep -q "$string" "$path" &> /dev/null; then
    echo "$string" >> "$path"
    echo "$string added to $path"
  else
    echo "$string already exists in $path"
  fi
}

# Function for run_steping headers
run_step() {
  local header_text="$1"
  local DISPLAY_COMMAND="echo"

  if [ "$(command -v figlet)" ]; then
    DISPLAY_COMMAND="figlet"
  fi

  echo "--------------------------------------"
  $DISPLAY_COMMAND "$header_text"
  log "$header_text"
  echo "--------------------------------------"
}

###START_PROGRAM###

# Check if Script is Run as Root
if [[ $EUID -ne 1000 ]]; then
  echo "You must be a normal user to run this script" 2>&1
  exit 1
fi

USERNAME=$(id -u -n 1000)

if [[ "/home/$USERNAME" != "$HOME" ]]; then
  exit 1
fi

# Configuration
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
mkdir -p "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Music"
mkdir -p "$HOME/.config/"

CUR_DIR=$(pwd)

sudo mkdir -p /root/.config/

# define what you want to install
INSTALL_JAVA=true
INSTALL_GO=true
INSTALL_LUA=true
INSTALL_C=true
INSTALL_DOCKER=true
INSTALL_TUI_FILE_MANAGER=true
INSTALL_CHROME=true
INSTALL_VSCODE=true
INSTALL_NVIM=true
INSTALL_YANDEX=true
INSTALL_WALLPAPER=true

# Log script start
log "Installation script started."

run_step "Sync Time"
sudo apt install -y ntp

run_step "UPDATE"
sudo apt update
sudo apt -y upgrade

run_step "Installing nala"
sudo apt install -y nala figlet curl

run_step "Refresh Mirrors"
yes | sudo nala fetch --auto

#add mirror refresh
run_step "Crontab setup"
cron_cmd='@reboot yes | nala fetch --auto'
(sudo crontab -l 2>/dev/null; echo "$cron_cmd") | sort -u | sudo crontab -

run_step "Start build-essential"
sudo nala install -y build-essential xdg-user-dirs vim
log "End build-essential"

# Remove PC Speaker Beep
run_step "Remove PC Speaker Beep"
sudo rmmod pcspkr

# run_step "ZSH"
# if [ ! "$(command -v zsh)" ]; then
#   sudo nala install -y zsh fonts-font-awesome zsh-syntax-highlighting
#   ln -sf "$CUR_DIR/.zsh" "$HOME/.zsh"
#   ln -s "$CUR_DIR/.zshrc" "$HOME/.zshrc"
# fi
run_step "Start ZSH + Oh My Zsh"

# Install Zsh and fonts
if ! command -v zsh >/dev/null; then
  if command -v nala >/dev/null; then
    sudo nala install -y zsh fonts-powerline fonts-font-awesome
  else
    sudo apt install -y zsh fonts-powerline fonts-font-awesome
  fi
fi

# Install Oh My Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Make zsh the default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# Copy custom .zshrc
[ -e "$HOME/.zshrc" ] && rm -rf "$HOME/.zshrc"
ln -sf "$CUR_DIR/.zshrc" "$HOME/.zshrc"

# Copy alias/env scripts if you're modular
[ -e "$HOME/.zsh" ] && rm -rf "$HOME/.zsh"
ln -sf "$CUR_DIR/.zsh" "$HOME/.zsh"

run_step "End Oh My Zsh"


run_step "Start Flatpak"
sudo nala install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "End Flatpak"

run_step "Start Nodejs"
if [ ! "$(command -v npm)" ]; then
  sudo nala update
  sudo nala install -y ca-certificates curl gnupg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  sudo nala update
  sudo nala install -y nodejs
fi
log "End Nodejs"

run_step "Start Python-add"
sudo nala install -y python3-pip python3-venv
log "End Python-add"

if [ $INSTALL_JAVA == true ]; then
  run_step "Java Start"
  sudo nala install -y default-jdk
  log "Java End"
fi

if [ $INSTALL_GO == true ]; then
  run_step "Go Start"
  sudo nala install -y golang
  log "Go End"
fi

if [ $INSTALL_LUA == true ]; then
  run_step "Lua Start"
  sudo nala install -y lua5.4 luarocks
  log "Lua End"
fi

if [ $INSTALL_C == true ]; then
  run_step "C Start"
  sudo nala install -y libcriterion-dev cppcheck gdb valgrind lldb gcovr ncurses-devel CSFML-devel
  #"$SCRIPT_DIR/criterion/install_criterion.sh"
  log "C End"
fi

run_step "Start Framwork & Header Updates"
sudo nala install -y linux-headers-"$(uname -r)" firmware-linux software-properties-common laptop-mode-tools
log "End Framwork & Header Updates"

if [ $INSTALL_DOCKER == true ]; then
  run_step "Docker Engine Start"
  if [ ! "$(command -v docker)" ]; then
    sudo nala update
    sudo nala install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo nala update
    sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if ! getent group docker > /dev/null; then
      echo "Creating group: docker"
      sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"
    sudo systemctl enable containerd.service
    sudo systemctl enable docker.service
  fi
  log "Docker Engine End"
fi

run_step "Start Virtualisation"
sudo nala install -y distrobox virt-manager
log "End Virtualisation"

run_step "Start Network Management"
sudo nala install -y nm-tray network-manager
sudo systemctl start NetworkManager.service
sudo systemctl enable NetworkManager.service
log "End Network Management"

run_step "Start System Utilities"
sudo nala install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
sudo systemctl enable avahi-daemon
sudo systemctl enable acpid
log "End System Utilities"

run_step "Start Terminal Emulators"
sudo nala install -y alacritty
sudo update-alternati[ -e "$HOME/.config/alacritty" ] && rm -rf "$HOME/.config/alacritty"
ln -sf "$CUR_DIR/alacritty" "$HOME/.config/alacritty"

ves --set x-terminal-emulator /usr/bin/alacritty
log "End Terminal Emulators"

run_step "Start Audio Control Start"
sudo nala install -y pulseaudio alsa-utils pavucontrol volumeicon-alsa
log "End Audio Control End"

run_step "Start System Information and Monitoring"
sudo nala install -y neofetch htop
log "End System Infor[ -e "$HOME/.config/neofetch" ] && rm -rf "$HOME/.config/neofetch"
ln -sf "$CUR_DIR/neofetch" "$HOME/.config/neofetch"
mation and Monitoring"

run_step "Start Screenshots"
sudo nala install -y flameshot
log "End Screenshots"

run_step "Start Printer Support"
sudo nala install -y cups simple-scan
sudo systemctl enable cups
log "End Printer Support"

run_step "Start Bluetooth Support"
sudo nala install -y bluez blueman
sudo systemctl enable bluetooth
log "End Bluetooth Support"

run_step "Start Menu and Window Managers"
sudo nala install -y numlockx rofi dunst libnotify-bin picom dmenu dbus-x11
run_step "Start Menu and Window Managers"

run_step "Start Text Editors"
sudo nala install -y vim
cp "$SCRIPT_DIR/vim/.vimrc" "$HOME"
log "End Text Editors"

run_step "Start Image Viewer"
sudo nala install -y viewnior sxiv ueberzug python3-pillow
log "End Image Viewer"

run_step "Start Wallpaper"
sudo nala install -y feh
log "End Wallpaper"

run_step "Start Media Player"
sudo nala install -y vlc mpv
log "End Media Player"

run_step "Start Music Player"
sudo flatpak install -y flathub com.spotify.Client io.bassi.Amberol
# spotify_player
sudo nala install -y libssl-dev libasound2-dev libdbus-1-dev
cargo install spotify_player --features sixel,daemon
log "End Music Player"

run_step "Start Document Viewer"
sudo nala install -y zathura
log "End Document Viewer"

run_step "Start X Window System and Input"
sudo apt -f install -y xorg xbacklight xinput xorg-dev xdotool brightnessctl
log "End X Window System and Input"

run_step "LOCK SCREEN Start"
sudo nala install -y libpam0g-dev libxcb-xkb-dev
if [ ! -d "/tmp/ly" ]; then
  git clone --recurse-submodules https://github.com/fairyglade/ly /tmp/ly
fi
cd /tmp/ly
make
sudo make install installsystemd
sudo systemctl enable ly.service
cd -
rm -rf /tmp/ly

# Configure xsessions
if [[ ! -d /usr/share/xsessions/i3.desktop ]]; then
  if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
  fi
  cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=i3
Comment=Manual Window Manager
Exec=i3
Icon=i3
Type=XSession
EOF
  sudo cp ./temp /usr/share/xsessions/i3.desktop
  rm ./temp
fi
run_step "LOCK SCREEN End"

run_step "WINDOW MANAGER Start"
sudo nala install -y i3 i3lock-fancy xautolock
[ -e "$HOME/.config/i3" ] && rm -rf "$HOME/.config/i3"
ln -sf "$CUR_DIR/i3" "$HOME/.config/i3"
run_step "WINDOW MANAGER End"

run_step "Theme Start"
# # Desktop Theme
# sudo nala install -y arc-theme
# # Icons
# if [ -z "$(sudo find /usr/share/icons/ -iname "Flat-Remix-*")" ]; then
#   if [ ! -d "/tmp/flat-remix" ]; then
#     git clone https://github.com/daniruiz/flat-remix.git /tmp/flat-remix
#   fi
#   sudo mv /tmp/flat-remix/Flat-Remix-* /usr/share/icons/
#   rm -rf /tmp/flat-remix
# fi
# # Cursor
# mkdir -p "$HOME/.icons/"
# if [ -z "$(sudo find "$HOME/.icons/" -name "oreo_spark_purple_cursors")" ]; then
#   tar -xvf "$SCRIPT_DIR/oreo-spark-purple-cursors.tar.gz"
#   sudo mv oreo_spark_purple_cursors "$HOME/.icons/"
# fi
# if [ -z "$(sudo find "$HOME/.icons/" -name "Bibata-Modern-Amber")" ]; then
#   tar -xvf "$SCRIPT_DIR/Bibata-Modern-Amber.tar.xz"
#   sudo mv Bibata-Modern-Amber "$HOME/.icons/"
# fi
#
# # Add config
# mkdir -p "$HOME/.config/gtk-3.0/"
# cp "$SCRIPT_DIR/gtk-3.0/.gtkrc-2.0" "$HOME/"
run_step "Theme End"

run_step "Wallpaper Start"
if [ ! -d "$HOME/wallpapers"]; then
    cp -r "$CUR_DIR/wallpapers" "$HOME/wallpapers"
fi

if [ ! -d "$HOME/wallpapers2"]; then
    cp -r "$CUR_DIR/wallpapers2" "$HOME/wallpapers2"
fi
run_step "Wallpaper End"

run_step "Start Kubectl"
if [ ! "$(command -v kubectl)" ]; then
  sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  # add kubectl completion for zsh
  mkdir -p $HOME/.zsh/
  kubectl completion zsh > /tmp/kubectl.zsh
  tail -n +20 /tmp/kubectl.zsh > $HOME/.zsh/kubectl.zsh
  rm /tmp/kubectl.zsh
fi
log "End Kubectl"

# run_step "Start Minikube"
# if [ ! "$(command -v minikube)" ]; then
#   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#   sudo install minikube-linux-amd64 /usr/local/bin/minikube
# fi
# log "End Minikube"

if [ $INSTALL_VSCODE == true ]; then
  run_step "Start VSCode"
  if [ ! "$(command -v code)" ]; then
    sudo nala install -y wget gpg apt-transport-https
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo nala update
    sudo nala install -y code
  fi
  log "End VSCode"
fi

if [ "$INSTALL_NVIM" = true ]; then
  run_step "Start Neovim"

  if ! command -v nvim >/dev/null; then
    echo "📦 Installing Neovim from source..."
    
    # Install dependencies
    if command -v nala >/dev/null; then
      sudo nala install -y ninja-build gettext cmake unzip curl build-essential
    else
      sudo apt install -y ninja-build gettext cmake unzip curl build-essential
    fi

    # Clone and build Neovim
    if [ ! -d "/tmp/neovim" ]; then
      git clone https://github.com/neovim/neovim /tmp/neovim
    fi
    cd /tmp/neovim
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    cd -
    sudo rm -rf /tmp/neovim
  fi

  log "End Neovim"
  run_step "Start Config NeoVim"

  # Only configure if config is missing
  if [ ! -d "$HOME/.config/nvim" ]; then
    echo "📂 Setting up Neovim config..."
    
    # Install Python + JS Neovim support
    pip install neovim --break-system-packages
    if ! command -v tree-sitter >/dev/null; then
      sudo npm install -g neovim tree-sitter-cli
    fi

    sudo apt install -y xclip  # For clipboard support

    # Clone user config
    [ -e "$HOME/.config/nvim" ] && rm -rf "$HOME/.config/nvim"
    ln -sf "$CUR_DIR/nvim" "$HOME/.config/nvim"
    sudo mkdir -p /root/.config
    sudo cp -r "$HOME/.config/nvim" /root/.config/nvim

    # Set as default editor
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 50
  fi

  # -----------------------------------------
  # Lazy.nvim bootstrapping (in case config doesn't do it automatically)
  # -----------------------------------------
  echo "🚀 Installing lazy.nvim plugin manager..."
  mkdir -p "$HOME/.config/nvim/lazy"
  git clone https://github.com/folke/lazy.nvim.git "$HOME/.config/nvim/lazy/lazy.nvim"
  sudo mkdir -p /root/.config/nvim/lazy
  sudo cp -r "$HOME/.config/nvim/lazy/lazy.nvim" /root/.config/nvim/lazy/lazy.nvim

  log "End Config NeoVim"
fi

run_step "CRONTAB"
sudo crontab "$CRONTAB_ROOT"

sudo chown -R "$USER":"$USER" "/home/$USER"

END=$(date +%s)

RUNTIME=$((END - START))

run_step "Type Your Password to make zsh your Default shell"
chsh -s /bin/zsh

run_step "Scrip executed in $RUNTIME s"

run_step "Reboot Now"

# Log script completion
log "Installation script completed."

