#!/usr/bin/env bash
# script LinuxWelt; author: David Wolski <pcwelt@gmail.com>;
cat <<HEREDOC

.____    .__                     __      __       .__   __
|    |   |__| ____  __ _____  __/  \    /  \ ____ |  |_/  |_
|    |   |  |/    \|  |  \  \/  |   \/\/   // __ \|  |\   __|
|    |___|  |   |  \  |  />    < \        /\  ___/|  |_|  |
|_______ \__|___|  /____//__/\_ \ \__/\  /  \___  >____/__|
        \/       \/            \/      \/       \/

Dieses Script dient dazu, Google Chromium als DEB aus dem PPA
https://launchpad.net/~phd/+archive/ubuntu/chromium-browser in
Ubuntu 22.04 LTS / 22.10 / 23.04 zu installieren. Falls Chromium
als Snap schon installiert ist, so entfernt das Script diese 
Version zuerst.

Achtung: Einstellungen, Lesezeichen und gespeicherte Kennworte 
aus dem installierten Chromium gehen dabei verloren und müssen
deshalb zuerst exportiert/gespeichert werden.

Einige Aktionen benötigen root-Rechte und das Script wird dann
'sudo' vor den betreffenden Befehlen aufrufen.

HEREDOC

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

read -r -p "Soll Chromium als Snap (falls vorhanden) nun de-installiert werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi

$SUDO snap remove chromium

read -r -p "Soll Chromium nun als DEB installiert werden werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi

$SUDO add-apt-repository ppa:phd/chromium-browser
$SUDO apt update 

echo '
Package: *
Pin: release o=LP-PPA-phd-chromium-browser
Pin-Priority: 1001
' | $SUDO tee /etc/apt/preferences.d/phd-chromium-browser

echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-phd-chromium-browser:${distro_codename}";' | $SUDO tee /etc/apt/apt.conf.d/52unattended-upgrades-chromium

$SUDO apt install -y chromium-browser

cat <<EOF


Alles erledigt. Um Chromium wieder als Snap zu installieren, bitte die beiden
Dateien '/etc/apt/preferences.d/phd-chromium-browser' und 
'/etc/apt/apt.conf.d/52unattended-upgrades-chromium' entfernen und dann
'sudo snap install chromium' aufrufen. 

EOF
