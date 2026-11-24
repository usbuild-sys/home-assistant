#!/bin/bash
# Run on ha-node as root. Installs labwatch, asks for the Telegram bot token + chat id once.
set -e
BASE=https://raw.githubusercontent.com/usbuild-sys/home-assistant/main/labwatch
curl -sL -o /usr/local/bin/labwatch.sh "$BASE/labwatch.sh" && chmod 755 /usr/local/bin/labwatch.sh

if [ ! -f /etc/labwatch.conf ]; then
  read -rp "Telegram bot token: " TOKEN
  read -rp "Telegram chat id (leave empty to look it up): " CID
  if [ -z "$CID" ]; then
    echo "Send any message to your bot in Telegram now, then press Enter."; read -r
    curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates" | grep -o '"chat":{"id":-\?[0-9]*' | sort -u
    read -rp "Chat id from above: " CID
  fi
  cat > /etc/labwatch.conf <<CONF
BOT_TOKEN="$TOKEN"
CHAT_ID="$CID"
# ip=name, one per entry
HOSTS=(
  "172.17.1.77=scrm (lab host)"
  "172.17.1.80=PBS"
  "172.17.1.111=SuiteCRM"
  "172.17.1.78=Traccar"
  "172.17.1.76=dash"
  "172.17.1.125=Home Assistant"
)
CONF
  chmod 600 /etc/labwatch.conf
fi

cat > /etc/cron.d/labwatch <<'CRON'
0 7 * * * root /usr/local/bin/labwatch.sh summary
CRON
/usr/local/bin/labwatch.sh test && echo "Installed. Check Telegram for the test message."
