#!/usr/bin/env bash

# --- CONFIG + SETUP ---
set +e
trap 'echo "⚠️  Error in: $CURRENT_STEP. Continuing..."; log "ERROR in: $CURRENT_STEP"' ERR

CURRENT_STEP="(init)"
START_FROM="$1"
SKIP=true

LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CUR_DIR=$(pwd)
USERNAME=$(id -un 1000)
HOME="/home/$USERNAME"

log() {
  local message="$1"
  sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

run_step() {
  local name="$1"
  shift
  if [[ -n "$START_FROM" && "$START_FROM" != "$name" && "$SKIP" != false ]]; then
    echo "⏩ Skipping $name"
    return
  fi
  SKIP=false
  CURRENT_STEP="$name"
  echo -e "\n🟢 Starting: $name"
  "$@"
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
precheck() {
  if [[ $EUID -eq 0 ]]; then
    echo "❌ Do not run this script as root. Run it as your user." >&2
    exit 1
  fi

  if [[ ! -d "$HOME" ]]; then
    echo "❌ Home directory $HOME does not exist." >&2
    exit 1
  fi

  sudo mkdir -p /root/.config
  mkdir -p "$HOME/.config" "$HOME/desktop" "$HOME/downloads" "$HOME/pictures" "$HOME/music"
}
run_step "Precheck" precheck


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

install_ntp() {
    display "Sync Time"
    sudo apt install -y ntp
}
run_step "Sync Time" install_ntp

update_apt() {
    display "UPDATE"
    sudo apt update
    sudo apt -y upgrade
}
run_step "UPDATE" update_apt

install_nala() {
    display "Setup nala"
    sudo apt install -y nala figlet curl
}
run_step "Setup nala" install_nala

refresh_mirrors() {
    display "Setup mirrors"
    yes | sudo nala fetch --auto

    #add mirror refresh
    display "Crontab setup"
    cron_cmd='@reboot yes | nala fetch --auto'
    (sudo crontab -l 2>/dev/null; echo "$cron_cmd") | sort -u | sudo crontab -
}
run_step "Setup mirrors" refresh_mirrors

install_essentials() {
    display "Setup build-essential"
    sudo nala install -y build-essential xdg-user-dirs vim

    # Remove PC Speaker Beep
    # display "Remove PC Speaker Beep"
    sudo rmmod pcspkr
}
run_step "Setup build-essential" install_essentials

setup_zsh() {
    display "Setup Zsh"
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
}
run_step "Setup zsh" setup_zsh


install_flatpak() {
  display "Setup flatpak"

  sudo nala install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}
run_step "Setup flatpak" install_flatpak

install_nodejs() {
    display "Setup nodejs"
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
}
run_step "Setup nodejs" install_nodejs

install_python() {
    display "Setup python"
    sudo nala install -y python3-pip python3-venv
}
run_step "Setup python" install_python

install_java() {
    display "Setup java"
    sudo nala install -y default-jdk
}
if [ $INSTALL_JAVA == true ]; then
  run_step "Setup java" install_java
fi

install_golang() {
    display "Setup go"
    sudo nala install -y golang
}
if [ $INSTALL_GO == true ]; then
  run_step "Setup go" install_golang
fi

install_lua() {
    display "Setup lua"
    sudo nala install -y lua5.4 luarocks
}
if [ $INSTALL_LUA == true ]; then
  run_step "Setup lua" install_lua
fi

install_c() {
    display "Setup c"
    sudo nala install -y libcriterion-dev cppcheck gdb valgrind lldb gcovr ncurses-devel CSFML-devel
}
if [ $INSTALL_C == true ]; then
  run_step "Setup c" install_c
fi

install_framework_and_header_updates() {
    display "Setup framework"
    sudo nala install -y linux-headers-"$(uname -r)" firmware-linux software-properties-common laptop-mode-tools
}
run_step "Setup framework" install_framework_and_header_updates

install_docker() {
    display "Setup docker"
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
}
if [ $INSTALL_DOCKER == true ]; then
    run_step "Setup docker" install_docker
fi

setup_virtualization() {
    display "Setup virtualization"
    sudo nala install -y distrobox virt-manager
}
run_step "Setup virtualization" setup_virtualization

setup_network_manager() {
    display "Setup network manager"
    sudo nala install -y nm-tray network-manager
    sudo systemctl start NetworkManager.service
    sudo systemctl enable NetworkManager.service
}
run_step "Setup network manager" setup_network_manager

Setup_system_utilities() {
    display "Setup system utilities"
    sudo nala install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
    sudo systemctl enable avahi-daemon
    sudo systemctl enable acpid
}
run_step "Setup system utilities" Setup_system_utilities

Setup_terminal_emulators() {
    display "Setup terminal emulators"
    sudo nala install -y alacritty
    [ -e "$HOME/.config/alacritty" ] && rm -rf "$HOME/.config/alacritty"
    ln -sf "$CUR_DIR/.config/alacritty" "$HOME/.config/alacritty"
    sudo update-alternatives --set x-terminal-emulator /usr/bin/alacritty
}
run_step "Setup terminal emulators" Setup_terminal_emulators

Setup_audio_control() {
    display "Setup audio control"
    sudo nala install -y pulseaudio alsa-utils pavucontrol volumeicon-alsa
}
run_step "Setup audio control" Setup_audio_control

Setup_system_monitoring() {
    display "Setup system monitoring"
    sudo nala install -y neofetch htop
    [ -e "$HOME/.config/neofetch" ] && rm -rf "$HOME/.config/neofetch"
    ln -sf "$CUR_DIR/.config/neofetch" "$HOME/.config/neofetch"
}
run_step "Setup system monitoring" Setup_system_monitoring

Setup_screenshots() {
    display "Setup screenshots"
    sudo nala install -y flameshot
}
run_step "Setup screenshots" Setup_screenshots

Setup_printer_support() {
    display "Setup printer support"
    sudo nala install -y cups simple-scan
    sudo systemctl enable cups
}
run_step "Setup printer support" Setup_printer_support

Setup_bluetooth_support() {
    display "Setup bluetooth support"
    sudo nala install -y bluez blueman
    sudo systemctl enable bluetooth
}
run_step "Setup bluetooth support" Setup_bluetooth_support

Setup_menu_and_wm() {
    display "Setup menu and window managers"
    sudo nala install -y numlockx rofi dunst libnotify-bin picom dmenu dbus-x11
}
run_step "Setup menu and window managers" Setup_menu_and_wm

Setup_text_editors() {
    display "Setup text editors"
    sudo nala install -y vim
    cp "$SCRIPT_DIR/vim/.vimrc" "$HOME"
}
run_step "Setup text editors" Setup_text_editors

Setup_image_viewers() {
    display "Setup image viewers"
    sudo nala install -y viewnior sxiv ueberzug python3-pillow
}
run_step "Setup image viewers" Setup_image_viewers

Setup_wallpaper() {
    display "Setup wallpaper"
    sudo nala install -y feh
}
run_step "Setup wallpaper" Setup_wallpaper

Setup_media_player() {
    display "Setup media player"
    sudo nala install -y vlc mpv
}
run_step "Setup media player" Setup_media_player

Setup_music_player() {
    display "Setup music player"
    sudo flatpak install -y flathub com.spotify.Client io.bassi.Amberol
    sudo nala install -y libssl-dev libasound2-dev libdbus-1-dev
    cargo install spotify_player --features sixel,daemon
}
run_step "Setup music player" Setup_music_player

Setup_document_viewer() {
    display "Setup document viewer"
    sudo nala install -y zathura
}
run_step "Setup document viewer" Setup_document_viewer

Setup_x_window_input() {
    display "Setup x window system and input"
    sudo apt -f install -y xorg xbacklight xinput xorg-dev xdotool brightnessctl
}
run_step "Setup x window system and input" Setup_x_window_input

Setup_lock_screen() {
    display "Setup lock screen"
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

    if [[ ! -f /usr/share/xsessions/i3.desktop ]]; then
      sudo mkdir -p /usr/share/xsessions
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
}
run_step "Setup lock screen" Setup_lock_screen

Setup_window_manager() {
    display "Setup window manager"
    sudo nala install -y i3 i3lock-fancy xautolock
    [ -e "$HOME/.config/i3" ] && rm -rf "$HOME/.config/i3"
    ln -sf "$CUR_DIR/.config/i3" "$HOME/.config/i3"
}
run_step "Setup window manager" Setup_window_manager

Setup_theme() {
    display "Setup theme"
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
}
run_step "Setup theme" Setup_theme

Setup_wallpapers() {
    display "Setup wallpapers"
    if [ ! -d "$HOME/wallpapers" ]; then
        cp -r "$CUR_DIR/wallpapers" "$HOME/wallpapers"
    fi

    if [ ! -d "$HOME/wallpapers2" ]; then
        cp -r "$CUR_DIR/wallpapers2" "$HOME/wallpapers2"
    fi
}
run_step "Setup wallpapers" Setup_wallpapers

Setup_kubectl() {
    display "Setup kubectl"
    if ! command -v kubectl >/dev/null; then
        sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
        mkdir -p "$HOME/.zsh/"
        kubectl completion zsh > /tmp/kubectl.zsh
        tail -n +20 /tmp/kubectl.zsh > "$HOME/.zsh/kubectl.zsh"
        rm /tmp/kubectl.zsh
    fi
}
run_step "Setup kubectl" Setup_kubectl

# Setup_minikube() {
#     display "Setup minikube"
#     if ! command -v minikube >/dev/null; then
#         curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#         sudo install minikube-linux-amd64 /usr/local/bin/minikube
#     fi
# }
# run_step "Setup minikube" Setup_minikube

Setup_vscode() {
    display "Setup vscode"
    if ! command -v code >/dev/null; then
        sudo nala install -y wget gpg apt-transport-https
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo nala update
        sudo nala install -y code
    fi
}
if [ "$INSTALL_VSCODE" = true ]; then
    run_step "Setup vscode" Setup_vscode
fi

Setup_neovim() {
    display "Setup neovim"
    if ! command -v nvim >/dev/null; then
        echo "📦 Installing Neovim from source..."
        if command -v nala >/dev/null; then
            sudo nala install -y ninja-build gettext cmake unzip curl build-essential
        else
            sudo apt install -y ninja-build gettext cmake unzip curl build-essential
        fi
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
}
if [ "$INSTALL_NVIM" = true ]; then
    run_step "Setup neovim" Setup_neovim
fi

Setup_neovim_config() {
    display "Setup neovim config"

    # Remove old config if it exists
    [ -e "$HOME/.config/nvim" ] && rm -rf "$HOME/.config/nvim"

    # Link user's Neovim config from script dir
    ln -sf "$CUR_DIR/.config/nvim" "$HOME/.config/nvim"

    # Setup lazy.nvim plugin manager
    mkdir -p "$HOME/.config/nvim/lazy"

    if [ ! -d "$HOME/.config/nvim/lazy/lazy.nvim/.git" ]; then
        git clone https://github.com/folke/lazy.nvim.git "$HOME/.config/nvim/lazy/lazy.nvim"
    fi

    # Link lazy.nvim for root as well
    sudo mkdir -p /root/.config/nvim/lazy
    sudo ln -sf "$HOME/.config/nvim/lazy/lazy.nvim" /root/.config/nvim/lazy/lazy.nvim

    # Install neovim support tools
    pip install neovim --break-system-packages

    if ! command -v tree-sitter >/dev/null; then
        sudo npm install -g neovim tree-sitter-cli
    fi

    sudo apt install -y xclip

    # Make Neovim the default editor
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 50
}

if [ "$INSTALL_NVIM" = true ]; then
    run_step "Setup neovim config" Setup_neovim_config
fi

Setup_crontab() {
    display "Setup crontab"
    sudo crontab "$CRONTAB_ROOT"
}
run_step "Setup crontab" Setup_crontab

Setup_home_permissions() {
    display "Fix home ownership"
    sudo chown -R "$USER":"$USER" "/home/$USER"
}
run_step "Fix home ownership" Setup_home_permissions

Setup_default_shell() {
    display "Make zsh default shell"
    chsh -s /bin/zsh
}
run_step "Make zsh default shell" Setup_default_shell

Finish_script() {
    display "Finish script"
    END=$(date +%s)
    RUNTIME=$((END - START))
    echo "⏱️ Script executed in $RUNTIME seconds"
}
run_step "Finish script" Finish_script

Setup_reboot_prompt() {
    display "Reboot now"
}
run_step "Reboot now" Setup_reboot_prompt

log "Installation script completed."

