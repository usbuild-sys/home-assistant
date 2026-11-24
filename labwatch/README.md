# labwatch – Telegram alerts when lab hosts go down

Runs on **ha-node** (separate box from the lab it watches).
- every 5 min: ping each host 3×; on a change, re-check 30 s later, then Telegram `🔴 DOWN` / `🟢 BACK UP`
- 08:02 daily: summary of all hosts (silence = the watcher itself is dead)
- config: `/etc/labwatch.conf` (bot token + chat id, chmod 600, **not in git**); edit `HOSTS=(...)` to add/remove
- install: `curl -sLO https://raw.githubusercontent.com/usbuild-sys/home-assistant/main/labwatch/install.sh && bash install.sh`

Limits: if home internet/power is down nothing can be sent. TODO: backup-freshness check (PBS / B2 sync age).
