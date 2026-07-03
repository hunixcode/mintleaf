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
echo "║   TRAITEMENT DE RETOUR - NETTOYAGE  ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. Vérification des applications et de l'horloge
echo "[1/4] Vérification des applications et de l'horloge..."
bash "$SCRIPT_DIR/Utils/verification_app.sh"
bash "$SCRIPT_DIR/Utils/verification_time.sh"
echo ""

# 2. Vérifier si des processus de l'utilisateur "pret" tournent encore
echo "[2/4] Vérification des processus de l'utilisateur 'pret'..."
PRET_PIDS=$(pgrep -u pret 2>/dev/null || true)
if [ -n "$PRET_PIDS" ]; then
    echo "Des processus de l'utilisateur 'pret' sont encore actifs :"
    ps -u pret
    echo ""
    echo "Veuillez redémarrer la machine (reboot), puis relancer ce script."
    exit 1
fi
echo "✓ Aucun processus actif pour l'utilisateur 'pret'"
echo ""

# 3. Suppression de tous les réseaux WiFi enregistrés
echo "[3/4] Suppression de tous les réseaux WiFi enregistrés..."
WIFI_CONNS=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ":802-11-wireless$" | cut -d: -f1 || true)
if [ -z "$WIFI_CONNS" ]; then
    echo "Aucun réseau WiFi enregistré."
else
    while IFS= read -r CONN; do
        echo "  Suppression du réseau : $CONN"
        nmcli connection delete "$CONN"
    done <<< "$WIFI_CONNS"
    echo "✓ Tous les réseaux WiFi ont été supprimés"
fi
echo ""

# 4. Suppression et recréation de l'utilisateur "pret"
echo "[4/4] Suppression et recréation de l'utilisateur 'pret'..."

# Supprimer l'utilisateur pret s'il existe
if id "pret" &>/dev/null; then
    echo "Suppression de l'utilisateur 'pret' et de son répertoire home..."
    userdel -r pret 2>/dev/null || true
    echo "✓ Ancien utilisateur 'pret' supprimé"
fi

# Supprimer le groupe pret s'il reste (userdel -r le supprime normalement)
if getent group pret &>/dev/null; then
    groupdel pret 2>/dev/null || true
fi

# Recréer l'utilisateur pret
echo "Création de l'utilisateur 'pret'..."
useradd -m -c "pret" pret
echo "pret:pret" | chpasswd
echo "✓ Utilisateur 'pret' recréé avec succès (mdp: pret)"
echo ""

echo "╔══════════════════════════════════════╗"
echo "║     NETTOYAGE TERMINÉ AVEC SUCCÈS   ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "La machine est prête pour un nouveau prêt."

