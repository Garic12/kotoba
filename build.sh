#!/usr/bin/env bash
# Baut die Emanote-Website lokal und startet einen Testserver.
# Nutzung: ./build.sh [port]   (Standard-Port: 8000)
set -Eeuo pipefail

cd "$(dirname "$0")"

PORT="${1:-8000}"
URL="http://localhost:${PORT}/Artikel"
DAEMON="nix-daemon.service"
# Über den Socket starten: systemd legt ihn sofort an und startet den
# Daemon bei der ersten Verbindung, dadurch gibt es kein Timing-Problem
SOCKET="nix-daemon.socket"
SERVER_PID=""
DAEMON_STARTED=0

stop_daemon() {
    # Nur stoppen, wenn dieses Skript den Daemon gestartet hat
    if [[ $DAEMON_STARTED -eq 1 ]]; then
        echo "Stoppe Nix-Daemon..."
        sudo systemctl stop "$SOCKET" "$DAEMON"
        DAEMON_STARTED=0
    fi
}

cleanup() {
    stop_daemon
    if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
        echo
        echo "Beende Python-Server..."
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM

if systemctl is-active --quiet "$DAEMON" || systemctl is-active --quiet "$SOCKET"; then
    echo "Nix-Daemon läuft bereits."
else
    echo "Starte Nix-Daemon..."
    sudo systemctl start "$SOCKET"
    DAEMON_STARTED=1
fi

echo "Baue Emanote-Website..."
if nix --accept-flake-config build -o ./result; then
    echo "Build erfolgreich!"
else
    echo "Build fehlgeschlagen." >&2
    exit 1
fi

stop_daemon

echo "Starte Python-Testserver unter ${URL}"
# Wegen "urlStrategy: pretty" verlinkt Emanote ohne ".html" (z.B. /Artikel/Kanji).
# GitHub Pages ergänzt das automatisch, http.server nicht, daher hier nachrüsten.
python3 - "$PORT" ./result <<'EOF' &
import functools, http.server, os, sys

class PrettyHandler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        p = super().translate_path(path)
        if not os.path.isfile(p) and os.path.isfile(p + ".html"):
            return p + ".html"
        return p

    # Nix-Store-Dateien haben als Datum 1970, sonst cached der Browser alte Builds
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def send_header(self, keyword, value):
        if keyword.lower() != "last-modified":
            super().send_header(keyword, value)

handler = functools.partial(PrettyHandler, directory=sys.argv[2])
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), handler).serve_forever()
EOF
SERVER_PID=$!

# Warten, bis der Server erreichbar ist, dann Browser öffnen
for _ in {1..50}; do
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "Python-Server konnte nicht gestartet werden (Port ${PORT} belegt?)." >&2
        exit 1
    fi
    if (exec 3<>"/dev/tcp/127.0.0.1/${PORT}") 2>/dev/null; then
        break
    fi
    sleep 0.1
done

xdg-open "$URL" >/dev/null 2>&1 &

echo "Website läuft. Beenden mit Strg+C."
wait "$SERVER_PID"
