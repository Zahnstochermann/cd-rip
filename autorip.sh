#!/bin/bash
#
# Autorip-Skript mit eingebetteter abcde-Konfig-Aufruf
#

# Verzeichnis des Skripts ermitteln
SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONF="$SCRIPT_DIR/abcde.conf"

# CD-Laufwerk
CDDEV="/dev/cdrom"

# Log-Verzeichnis
LOGDIR="$HOME/Musik/logs"
mkdir -p "$LOGDIR"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOGFILE="$LOGDIR/rip_$DATE.log"

echo "==============================================="
echo "Starte Ripping: $DATE"
echo "CD-Laufwerk: $CDDEV"
echo "Logfile: $LOGFILE"
echo "==============================================="

# CD-Info anzeigen
echo "Lese CD-Informationen..."
abcde -c "$CONF" -d "$CDDEV" -i

# Ripping starten mit Live-Status
echo "Starte Ripping..."
abcde -c "$CONF" -d "$CDDEV" -N -o flac,mp3 | while IFS= read -r line; do
    if [[ $line == *"Ripping track"* ]]; then
        echo "🎵 $line"
    elif [[ $line == *"Writing"* ]]; then
        echo "💾 $line"
    else
        echo "$line"
    fi
done >>"$LOGFILE" 2>&1

# Erfolg prüfen
if [ $? -eq 0 ]; then
    echo "✅ Ripping erfolgreich abgeschlossen."
else
    echo "❌ Fehler beim Ripping. Siehe Logfile: $LOGFILE"
fi

# CD auswerfen
echo "Werfe CD aus..."
eject "$CDDEV"

echo "Fertig: $DATE"
echo "==============================================="
