#!/bin/bash

set -e

MISSING=""
MEDIA_INSTALLED=0

for cmd in vlc zotero; do
	if ! command -v "$cmd" &>/dev/null; then
		MISSING="$MISSING $cmd"
	fi
done

if command -v mednum-desktop-player &>/dev/null; then
	MEDIA_INSTALLED=1
fi

if [ -z "$MISSING" ] && [ "$MEDIA_INSTALLED" = 1 ]; then
	echo ""
	echo "Everything is already installed !"
	echo ""
	exit 0
fi

apt update

if ! command -v vlc &>/dev/null; then
	echo "!=====VLC is not installed yet=====!"
	sleep 2
	echo ""
	echo "Installing VLC.."
	echo ""
	apt install vlc -y
fi

if ! command -v zotero &>/dev/null; then
	echo "!=====Zotero is not installed yet=====!"
	sleep 2
	echo ""
	echo "Installing Zotero..."
	echo ""
	wget -qO- https://raw.githubusercontent.com/retorquere/zotero-pkg/master/install.sh | bash
fi

if ! command -v mednum-desktop-player &>/dev/null; then
	echo "!=====Mediatheque Numérique is not installed yet=====!"
	sleep 2
	echo ""
	echo "Downloading and installing Mediatheque Numerique..."
	echo ""
	MEDNUM_DEB_URL="https://s3.eu-west-1.amazonaws.com/vodstorage.arte.tv/desktop-player/linux/mednum/Mediatheque%20Numerique%20Desktop%20Player%20Setup.deb"
	MEDNUM_DEB_PATH="/tmp/mednum-desktop-player.deb"
	wget -O "$MEDNUM_DEB_PATH" "$MEDNUM_DEB_URL"
	apt install "$MEDNUM_DEB_PATH" -y
	rm -f "$MEDNUM_DEB_PATH"
fi

echo ""
echo "[STATUS] Installation completed"
echo ""

which vlc zotero mednum-desktop-player || true
