# labwatch – Telegram alerts when lab hosts go down

Runs on **ha-node** (separate box from the lab it watches).
- 07:00 daily: checks every host; a host is only reported DOWN after 3 failed tries 2 min apart; one Telegram report (silence = the watcher itself is dead)
- `labwatch.sh check` (instant DOWN/BACK UP alerts) still exists if a frequent cron line is added later
- config: `/etc/labwatch.conf` (bot token + chat id, chmod 600, **not in git**); edit `HOSTS=(...)` to add/remove
- install: `curl -sLO https://raw.githubusercontent.com/usbuild-sys/home-assistant/main/labwatch/install.sh && bash install.sh`

Limits: if home internet/power is down nothing can be sent. TODO: backup-freshness check (PBS / B2 sync age).
