#!/bin/bash
# labwatch: ping lab hosts, Telegram alert on state change, optional daily summary.
# Usage: labwatch.sh check   (cron every 5 min)
#        labwatch.sh summary (cron once a day)
#        labwatch.sh test    (send a test message)
CONF=/etc/labwatch.conf
STATE=/var/lib/labwatch
. "$CONF" || exit 1          # provides BOT_TOKEN, CHAT_ID, HOSTS
mkdir -p "$STATE"

send() {
  curl -s -m 20 "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${CHAT_ID}" --data-urlencode "text=$1" >/dev/null
}
up() { ping -c3 -W2 -q "$1" >/dev/null 2>&1; }

case "$1" in
  check)
    for entry in "${HOSTS[@]}"; do
      ip=${entry%%=*}; name=${entry#*=}; f="$STATE/$ip"
      old=$(cat "$f" 2>/dev/null || echo up)
      if up "$ip"; then new=up; else new=down; fi
      if [ "$new" != "$old" ]; then
        if [ "$new" = down ]; then
          # confirm before alerting: second try 30s later
          sleep 30; up "$ip" && continue
          send "🔴 DOWN: $name ($ip) — $(date '+%b %d %H:%M')"
        else
          send "🟢 BACK UP: $name ($ip) — $(date '+%b %d %H:%M')"
        fi
        echo "$new" > "$f"
      fi
    done ;;
  summary)
    # morning report: a host is only reported down after 3 failed tries, 2 min apart
    down=(); ok=0
    for entry in "${HOSTS[@]}"; do
      ip=${entry%%=*}; name=${entry#*=}; alive=0
      for try in 1 2 3; do
        if up "$ip"; then alive=1; break; fi
        [ $try -lt 3 ] && sleep 120
      done
      if [ $alive = 1 ]; then ok=$((ok+1)); else down+=("🔴 $name ($ip)"); fi
    done
    if [ ${#down[@]} -eq 0 ]; then
      send "✅ Lab check $(date '+%b %d'): all ${ok} hosts up"
    else
      msg="⚠️ Lab check $(date '+%b %d'): ${#down[@]} DOWN, ${ok} up"
      for d in "${down[@]}"; do msg+=$'\n'"$d"; done
      send "$msg"
    fi ;;
  test) send "labwatch test from $(hostname) ✅" ;;
  *) echo "usage: $0 check|summary|test"; exit 1 ;;
esac
