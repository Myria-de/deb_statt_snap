#!/usr/bin/env bash
# script LinuxWelt; author: David Wolski <pcwelt@gmail.com>;
cat <<HEREDOC

.____    .__                     __      __       .__   __
|    |   |__| ____  __ _____  __/  \    /  \ ____ |  |_/  |_
|    |   |  |/    \|  |  \  \/  |   \/\/   // __ \|  |\   __|
|    |___|  |   |  \  |  />    < \        /\  ___/|  |_|  |
|_______ \__|___|  /____//__/\_ \ \__/\  /  \___  >____/__|
        \/       \/            \/      \/       \/

Dieses Script dient dazu, einen als als Snap installierten
Firefox in Ubuntu 22.04 LTS / 22.10 / 23.04 gegen Firefox aus
dem PPA https://launchpad.net/~mozillateam/+archive/ubuntu/ppa
auszutauschen.

Achtung: Einstellungen, Lesezeichen und gespeicherte Kennworte 
aus dem installierten Firefox gehen dabei verloren und müssen
deshalb zuerst exportiert/gespeichert werden.

Einige Aktionen benötigen root-Rechte und das Script wird dann
'sudo' vor den betreffenden Befehlen aufrufen.

HEREDOC

SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

read -r -p "Soll Firefox als Snap nun de-installiert werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi

$SUDO snap remove firefox

read -r -p "Soll Firefox nun als DEB installiert werden werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi

$SUDO add-apt-repository ppa:mozillateam/ppa

echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | $SUDO tee /etc/apt/preferences.d/mozilla-firefox

echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | $SUDO tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
$SUDO apt update
$SUDO apt -y install firefox firefox-locale-de

cat <<EOF


Alles erledigt. Um Firefox wieder als Snap zu installieren, bitte die beiden
Dateien '/etc/apt/preferences.d/mozilla-firefox' und 
'/etc/apt/apt.conf.d/51unattended-upgrades-firefox' entfernen und dann
'sudo snap install firefox' aufrufen. 

EOF
