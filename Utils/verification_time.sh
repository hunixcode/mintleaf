#!/bin/bash

echo ""
echo "[SYSTEM] Checking Timedatectl status..."
echo ""

CURRENT_TZ=$(timedatectl show -p Timezone --value 2>/dev/null)
CURRENT_NTP=$(timedatectl show -p NTP --value 2>/dev/null)

if [ "$CURRENT_TZ" = "Pacific/Tahiti" ] && [ "$CURRENT_NTP" = "yes" ]; then
	echo ""
	echo "[STATUS] Everything is perfectly set up"
	echo ""
	exit 0
fi

timedatectl set-ntp true
timedatectl set-timezone Pacific/Tahiti

sleep 2
