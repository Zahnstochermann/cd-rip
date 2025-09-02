#!/bin/bash
#
# Autorip-Skript mit eigener abcde-Konfiguration
#

# Pfade
SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONF="$SCRIPT_DIR/abcde.conf"
CDDEV="/dev/cdrom"

# Log-Verzeichnis
LOGDIR="$HOME/Musik/logs"
mkdir -p "$LOGDIR"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOGFILE="$LOGDIR/rip_$DATE.log"

echo "==============================================="
echo "📀 Starte Ripping: $DATE"
echo "CD-Laufwerk: $CDDEV"
echo "Konfiguration: $CONF"
echo "Logfile: $LOGFILE"
echo "==============================================="

# Direkt Ripping mit Live-Status starten
echo "🎶 Starte Ripping..."
abcde -c "$CONF" -d "$CDDEV" -N -o flac,mp3 2>&1 | tee >(while IFS= read -r line; do
    if [[ $line == *"Ripping track"* ]]; then
        echo "🎵 $line"
    elif [[ $line == *"Encoding"* ]]; then
        echo "💾 $line"
    elif [[ $line == *"Writing"* ]]; then
        echo "📂 $line"
    fi
done) >>"$LOGFILE"

# Erfolg prüfen
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ Ripping erfolgreich abgeschlossen."
else
    echo "❌ Fehler beim Ripping. Siehe Logfile: $LOGFILE"
fi

# CD auswerfen
echo "⏏️  Werfe CD aus..."
eject "$CDDEV"

echo "Fertig: $DATE"
echo "==============================================="
