#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

echo "Starte Nix-Daemon..."
sudo systemctl start nix-daemon.service

echo "Baue Emanote-Website..."
if nix build -o ./result; then
    echo "Build erfolgreich!"
else
    echo "Build fehlgeschlagen."
    sudo systemctl stop nix-daemon.service
    exit 1
fi

echo "Stoppe Nix-Daemon..."
sudo systemctl stop nix-daemon.service

echo "Starte Python-Testserver unter http://localhost:8000"
python -m http.server 8000 --directory ./result

