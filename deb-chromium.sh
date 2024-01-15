#!/usr/bin/env bash
# script LinuxWelt; author: David Wolski <pcwelt@gmail.com>;
cat <<HEREDOC

.____    .__                     __      __       .__   __
|    |   |__| ____  __ _____  __/  \    /  \ ____ |  |_/  |_
|    |   |  |/    \|  |  \  \/  |   \/\/   // __ \|  |\   __|
|    |___|  |   |  \  |  />    < \        /\  ___/|  |_|  |
|_______ \__|___|  /____//__/\_ \ \__/\  /  \___  >____/__|
        \/       \/            \/      \/       \/

Dieses Script dient dazu, Google Chromium als DEB von
https://freeshell.de/phd/chromium/ (Linux-Mint-Version) in
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
$SUDO apt -y remove chromium-browser

read -r -p "Soll Chromium nun als DEB installiert werden werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi

#https://freeshell.de/
source /etc/lsb-release
echo "deb https://freeshell.de/phd/chromium/${DISTRIB_CODENAME} /" \
| $SUDO tee /etc/apt/sources.list.d/phd-chromium.list

#deprecated
#$SUDO apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 869689FE09306074
cd ~
gpg --no-default-keyring --keyring gnupg-ring:~/phd-ubuntu-chromium-browser.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 869689FE09306074
$SUDO  mv phd-ubuntu-chromium-browser.gpg /etc/apt/trusted.gpg.d/
$SUDO  chown root:root /etc/apt/trusted.gpg.d/phd-ubuntu-chromium-browser.gpg
$SUDO  chmod ugo+r /etc/apt/trusted.gpg.d/phd-ubuntu-chromium-browser.gpg
$SUDO  chmod go-w /etc/apt/trusted.gpg.d/phd-ubuntu-chromium-browser.gpg

echo '
# chromium
Package: *
Pin: release origin "freeshell.de"
Pin-Priority: 1001

Package: chromium*
Pin: origin "freeshell.de"
Pin-Priority: 700

' | $SUDO tee /etc/apt/preferences.d/phd-chromium-browser

echo 'Unattended-Upgrade::Origins-Pattern {"site=freeshell.de"};' | $SUDO tee /etc/apt/apt.conf.d/52unattended-upgrades-chromium
$SUDO apt update 
$SUDO apt install -y chromium

cat <<EOF

Alles erledigt. Um Chromium wieder als Snap zu installieren, bitte die beiden
Dateien '/etc/apt/preferences.d/phd-chromium-browser' und 
'/etc/apt/apt.conf.d/52unattended-upgrades-chromium' entfernen und dann
'sudo snap install chromium' aufrufen. 

EOF
