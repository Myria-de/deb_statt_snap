#!/usr/bin/env bash
# script LinuxWelt; author: David Wolski, Thorsten Eggeling  <pcwelt@gmail.com>;
cat <<HEREDOC

.____    .__                     __      __       .__   __
|    |   |__| ____  __ _____  __/  \    /  \ ____ |  |_/  |_
|    |   |  |/    \|  |  \  \/  |   \/\/   // __ \|  |\   __|
|    |___|  |   |  \  |  />    < \        /\  ___/|  |_|  |
|_______ \__|___|  /____//__/\_ \ \__/\  /  \___  >____/__|
        \/       \/            \/      \/       \/

Dieses Script dient dazu, einen als als Snap installierten
Firefox in Ubuntu 22.04 LTS / 22.10 / 23.04 gegen Firefox aus
dem Mozilla-Repository https://packages.mozilla.org
auszutauschen.

Achtung: Einstellungen, Lesezeichen und gespeicherte Kennworte 
aus dem installierten Snap-Firefox gehen dabei verloren und müssen
deshalb zuerst exportiert/gespeichert werden.

Einige Aktionen benötigen root-Rechte und das Script wird dann
'sudo' vor den betreffenden Befehlen aufrufen.

HEREDOC
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

if pgrep -x "firefox" > /dev/null
then
    echo "Bitte Firefox zuerst beenden"
    exit 1
fi

read -r -p "Haben Sie ein Backup des Snap-Benutzerprofils erstellt? Soll Firefox als Snap jetzt deinstalliert werden? [j/n] " response
response=${response,,}    # tolower
if ! [[ "$response" =~ ^(ja|j)$ ]]; then
  exit
fi


$SUDO snap remove firefox

if [ ! -e /etc/apt/keyrings ]
then
$SUDO install -d -m 0755 /etc/apt/keyrings
fi


# wget?
if [ -z $(which wget) ]
then
echo "Installiere wget"
sudo apt -y install wget
fi

wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | $SUDO tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk 'BEGIN{code=0}/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") {print "\nDer Fingeabdruck des Schlüssels stimmt überein: ("$0").\n"} else {print "\nPrüfung fehlgeschlagen: Der Fingerabdruck ("$0") stimmt nicht überein.\n";code=1}} END{exit code}'
if [ $? == 1 ]
then
echo "Abbruch"
exit 1
fi

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | $SUDO tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | $SUDO tee /etc/apt/preferences.d/mozilla 

echo 'Unattended-Upgrade::Origins-Pattern {"site=packages.mozilla.org"};' | $SUDO tee /etc/apt/apt.conf.d/52unattended-upgrades-firefox

$SUDO apt update && $SUDO apt -y --allow-downgrades install firefox
$SUDO apt -y --allow-downgrades install firefox-l10n-de
