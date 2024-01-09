# Firefox und Chromium als DEB-Paket für Ubuntu installieren

**Update 08.01.2024:** Das Firefox-Systempaket aus dem PPA https://launchpad.net/~mozillateam/+archive/ubuntu/ppa ist zurzeit ohne Unterstützung für die VA-API (siehe https://github.com/Myria-de/Hardware-video-acceleration) kompiliert. Wer die VA-API für die Hardwarebeschleunigung in Firefox verwenden möchte, muss daher das Binärpaket von Mozilla verwenden (https://ftp.mozilla.org/pub/firefox/releases/, siehe im letzten Punkt dieses Artikels). 

Folgen Sie der nachfolgenden Anleitung, um das Systempaket aus dem PPA zu installieren. Danach laden Sie beispielsweise https://ftp.mozilla.org/pub/firefox/releases/121.0/linux-x86_64/de/ herunter und entpacken das Archiv in Ihr Home-Verzeichnis. Es ist allerdings nicht zwingend erforderlich, das Snap-Paket zu entfernen. Das Binär- und Snap-Paket lässt sich auch nebeneinander verwenden.

**Wichtig:** Eine Deinstallation des Snap-Pakets löscht alle vorhandenen Profildaten, Lesezeichen und eventuell gespeicherten Passwörter. Diese Daten sollte man deshalb zuvor sichern  und danach im klassischen DEB-Browser wiederherstellen.

# Firefox-Profil sichern
Bevor Sie die Snap-App entfernen, erstellen Sie ein Backup Ihres Firefox-Profils. Das ist sinvoll, wenn Sie in Firefox Lesezeichen, Passwörter etc. speichern. Zu Sicherheit sollten Sie ein Backup auch erstellen, wenn Sie sich in Firefox mit einem Mozilla-Konto anmelden und die Synchronisierung der Daten aktiviert haben. Achten Sie darauf, dass die Synchronisierung abgeschlossen ist.

Wo der Profilodner liegt und wie er heißt ermittlen Sie über die URL "about:profiles". Bei einer Snap-Installation heißt er beispielsweise "88f7mmyo.default" und liegt standardmäßig im Ordner "snap/firefox/common/.mozilla/firefox" in Ihrem Home-Verzeichnis.

**Beenden Sie Firefox** und packen Sie den Ordner beispielsweise über den Dateimanager in eine ZIP- oder xz-Datei.

# Firefox-Profil wiederherstellen
Die Wiederherstellung ist nur möglich, wenn Sie die gleiche oder einen neurer Firefox-Version verwenden. Wenn Sie das Systempaket oder die Binärdateien von Mozilla eingerichtet haben, starten Sie Firefox und ermittlen Sie über "about:profiles" den Profilordner. **Beenden Sie Firefox wieder**. Über den Dateimanager benenen Sie den Profilordner um beispielsweise von "ogup4l3n.default-release" in "ogup4l3n.default-release.001". Beim Systempaket liegt das Profil im versteckten Ordner ".mozilla/firefox" (im Dateimanager einblenden mit Strg-H).
Danach erstellen Sie den neuen Ordner "ogup4l3n.default-release". Kopieren Sie den Inhalt des gesicherten Profilordners - nicht den Ordner selbst - in den Ordner "ogup4l3n.default-release". In unserem Beispiel kopieren Sie den Inhalt von "88f7mmyo.default" in den Ordner "ogup4l3n.default-release"

# Chromium-Profil sichern
Chromium synchronisiert die Benutzerdaten automatisch, wenn Sie mit einem Google-Konto angemeldet sind. Für ein manuelles Backup ermitteln Sie in Chromium den Profilpfad über die URL "chrome://version". Bei er Snap-Version liegt er im Ordner "snap/chromium/common/chromium/Default" in Ihrem Home-Verzeichnis.

**Beenden Sie Chromium** und packen Sie den Ordner in ein ZIP- oder xz-Archiv. 

# Chromium-Profil wiederherstellen
Auch bei Chromium muss die Version von der das Backup stammt gleich oder neuer wie die jetzt verwendete Version sein. Starten Sie die neu installierte Chromium-Version und ermitteln Sie den Profilpfad über die URL "chrome://version". Beim Systempaket wird der versteckte Ordner ".config/chromium/Default" verwendet (einblenden mit Strg-H).  **Beenden Sie Chromium**. Benennen Sie den Ordner um und kopieren Sie den Ordner "default" aus dem Backup nach ".config/chromium".

# Ubuntu mit Snap-Paketen
Als Canonical ausgerechnet Chromium und dann auch noch den Standardbrowser Firefox als Snap-Paket in Ubuntu auslieferte, war die Skepsis bei vielen Anwendern zurecht groß. Denn die Browser starten als Snap zu langsam, und einige Add-Ons wollten auch nicht mehr funktionieren, weil Berechtigungen fehlen. Mittlerweile hat Canonical bei der Einbindung von Firefox nachgebessert - der Start ist deutlich flotter und viele Erweiterungen wie etwa die Gnome-Browsererweiterung zur Einbindung von Gnome-Shell-Extensions von https://extensions.gnome.org funktionieren wieder. Dennoch bleibt der Start auf Systemen mit schwächeren CPUs zunächst bei beiden Browsern schleppend, denn Snaps liefern ein gepacktes Dateisystem mit, das erst mal dekomprimiert werden will.

Firefox und Chromium gibt es in den aktuellen Ubuntus nicht mehr in den offiziellen Paketquellen. Allerdings liefern weiterhin PPAs, also externe Paketquellen, die Webbrowser stets aktuell in der üblichen Form als DEB-Paket aus: Für Firefox gibt es von der Mozilla Foundation das PPA https://launchpad.net/~mozillateam/+archive/ubuntu/ppa und für Chromium bietet sich https://launchpad.net/~phd/+archive/ubuntu/chromium-browser an. Eine Schwierigkeit ist es aber, Firefox oder Chromium als Snap erst einmal loszuwerden. Denn bei dem vorhandenen DEB-Paket in den Standardpaketquellen handelt es sich um einen Platzhalter, der immer wieder das Snap installiert. Auch ein Systemupdate würde den als DEB installierten Firefox wieder gegen das Snap-Paket austauschen. 

**Es ist also mehr zu beachten:** Per APT-Pinning muss das nachträglich installierte DEB eine höhere Priorität bekommen als das Snap-Paket aus den regulären Quellen. Gut ist es außerdem, falls die unbeaufsichtigten Updates aktiviert sind, diese auf Firefox beziehungsweise Chromium automatisch auf den neusten Stand bringen. Insgesamt kommen hier eine Menge kleine Handgriffe im Terminal zusammen, die in der Wiederholung auf mehreren Ubuntu-Systemen lästig werden. Wir haben deshalb für die Installation von Firefox und Chromium über die genannten PPAs jeweils ein Shell-Script erstellt, dass diese Handgriffe übernimmt und dabei gut nachvollziehbar ist. Für Firefox ist das Script "deb-firefox.sh" im Unterverzeichnis "Software" auf der Heft-DVD, und für Chromium erledigt "deb-chromium.sh" die Installation. Zuvor werden die Browser als Snap erst deinstalliert, falls vorhanden. Diese Aktionen verlangen nach dem sudo-Passwort und fragen dies im Terminal zuvor ab. Um eines der Scripts zu starten, kopiert man es in einen beliebigen Ordner, macht es mit
```
chmod +x deb-firefox.sh
```
ausführbar und ruft es dann mit
```
./deb-firefox.sh
```
auf. Das Script "deb-chromium.sh" verlangt die gleiche Behandlung. Die weiteren Schritte sind in der Ausgabe des jeweiligen Scripts erläutert und es gibt auch eine kurze Anleitung, wieder das Snap zu installieren, falls gewünscht.

# Firefox über das Binärpaket installieren
Das Binärpaket von https://ftp.mozilla.org/pub/firefox/releases/ lässt sich neben dem Systempaket installieren und nutzen (nicht gleichzeitig starten). Gehen Sie in den Ordner mit der gewünschten Version, zurzeit beispielsweise https://ftp.mozilla.org/pub/firefox/releases/102.0.1 (oder höher). Wechseln Sie in den Ordner "linux-x86_64/de/" und laden Sie für unser Beispiel "firefox-102.0.1.tar.bz2" herunter. Entpacken Sie das Archiv beispielsweise in den Ordner "firefox" in Ihrem Home-Verzeichnis. Starten Sie firefox aus diesem Ordnern. Danch stellen Sie den Profilordner wieder her, wie oben beschrieben.


