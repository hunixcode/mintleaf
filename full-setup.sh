#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
    echo "Veuillez exécuter ce script en tant que root."
    exit 1
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        FULL SETUP - LINUX MINT      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Mise à jour complète du système
echo "[1/4] Mise à jour complète du système..."
apt update
apt upgrade -y
echo "✓ Système mis à jour"
echo ""

# 2. Installation des applications
echo "[2/4] Installation des applications..."
bash "$SCRIPT_DIR/Utils/verification_app.sh"
echo ""

# 3. Vérification de l'horloge
echo "[3/4] Vérification de l'horloge système..."
bash "$SCRIPT_DIR/Utils/verification_time.sh"
echo ""

# 4. Création de l'utilisateur "pret"
echo "[4/4] Création de l'utilisateur 'pret'..."
if id "pret" &>/dev/null; then
    echo "L'utilisateur 'pret' existe déjà, mise à jour du mot de passe."
else
    useradd -m -c "pret" pret
fi
echo "pret:pret" | chpasswd
echo "✓ Utilisateur 'pret' créé (mdp: pret)"
echo ""

echo "╔══════════════════════════════════════╗"
echo "║     INSTALLATION TERMINÉE           ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Applications installées :"
which vlc zotero mednum-desktop-player 2>/dev/null || true
echo ""
echo "Time zone / NTP :"
timedatectl status | grep -E "(Time zone|NTP)" || true
