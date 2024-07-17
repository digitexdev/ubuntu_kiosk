#!/bin/bash

# User-defined variables
USER="$1"
PASSWORD="$2"
URL="$3"

# Validate input
if [[ -z "$USER" || -z "$PASSWORD" || -z "$URL" ]]; then
    echo "Usage: $0 <USER> <PASSWORD> <URL>"
    exit 1
fi

# Update and install necessary packages
sudo apt update
sudo apt install -y gnome-shell gnome-session dbus-x11
sudo snap install chromium

#add digitex logo to spinner theme
sudo chmod 644 watermark.png

sudo mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark_original.png

sudo cp watermark.png /usr/share/plymouth/themes/spinner/watermark.png

# Create a systemd user service to start Chromium in kiosk mode
sudo mkdir -p /home/$USER/.config/systemd/user
sudo chown -R $USER:$USER /home/$USER/.config/systemd
sudo bash -c "cat > /home/$USER/.config/systemd/user/kiosk.service <<EOF
[Unit]
Description=Kiosk Mode

[Service]
ExecStart=/snap/bin/chromium --incognito --kiosk --noerrdialogs --disable-infobars --password-store=basic $URL
Restart=always

[Install]
WantedBy=default.target
EOF"

# Set environment variables and enable/start the systemd user service
sudo -u $USER bash -c 'eval $(dbus-launch --sh-syntax); export XDG_RUNTIME_DIR="/run/user/$(id -u)"; systemctl --user enable kiosk.service; systemctl --user start kiosk.service'

# Disable GNOME screen lock and power management
sudo -u $USER bash -c 'eval $(dbus-launch --sh-syntax); export XDG_RUNTIME_DIR="/run/user/$(id -u)"; 
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 300
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 0'

# Configure autologin for the user
sudo sed -i "s/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/" /etc/gdm3/custom.conf
sudo sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = $USER/" /etc/gdm3/custom.conf

# Reboot to apply changes
#echo "Rebooting to apply changes..."
#sudo reboot
#Disable SIDE BAR
# Disable SIDE BAR
sudo -u $USER -H gnome-extensions disable ubuntu-dock@ubuntu.com

# Disable top bar
# mkdir -p /home/$USER/.local/share/gnome-shell/extensions
# mv hidetopbarmathieu.bidon.ca.v100.shell-extension /home/$USER/.local/share/gnome-shell/extensions/
# sudo -u $USER -H gnome-extensions enable hidetopbar@mathieu.bidon.ca
