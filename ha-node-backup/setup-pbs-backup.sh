#!/bin/bash
# Add Proxmox Backup Server storage to this PVE node, create a nightly 02:00 backup job
# for all guests, and run the first backup now. Run on the PVE host (ha-node) as root.
# Asks for the PBS password once; everything else is automatic.
set -e
PBS_IP="${PBS_IP:-172.17.1.80}"
STORE_ID="${STORE_ID:-pbs}"
LOG=/root/pbs-setup-$(date +%F-%H%M).log
exec > >(tee -a "$LOG") 2>&1

echo "== 1/6 Checking PBS at $PBS_IP:8007"
if ! timeout 5 bash -c "</dev/tcp/$PBS_IP/8007" 2>/dev/null; then
  echo "!! Cannot reach PBS at $PBS_IP:8007. Is the home lab host (172.17.1.77) up? Nothing changed."; exit 1
fi

read -rp "PBS user [root@pam]: " PBS_USER; PBS_USER=${PBS_USER:-root@pam}
read -rsp "PBS password for $PBS_USER: " PBS_PASS; echo

echo "== 2/6 Reading PBS certificate fingerprint"
FP=$(echo | openssl s_client -connect "$PBS_IP:8007" 2>/dev/null | openssl x509 -noout -fingerprint -sha256 | cut -d= -f2)
[ -n "$FP" ] || { echo "!! Could not read fingerprint"; exit 1; }
echo "   $FP"

echo "== 3/6 Finding datastores"
STORES=$(pvesm scan pbs "$PBS_IP" "$PBS_USER" --password "$PBS_PASS" --fingerprint "$FP" | awk 'NR>0{print $1}')
echo "$STORES" | sed 's/^/   /'
N=$(echo "$STORES" | grep -c . || true)
if [ "$N" -eq 1 ]; then DS=$STORES; else read -rp "Which datastore? " DS; fi
echo "   using datastore: $DS"

echo "== 4/6 Adding storage '$STORE_ID'"
if pvesm status | awk '{print $1}' | grep -qx "$STORE_ID"; then
  echo "   storage '$STORE_ID' already exists, skipping"
else
  pvesm add pbs "$STORE_ID" --server "$PBS_IP" --datastore "$DS" --username "$PBS_USER" \
    --password "$PBS_PASS" --fingerprint "$FP" --content backup
fi
pvesm status | grep -E "^Name|^$STORE_ID"

echo "== 5/6 Creating nightly 02:00 backup job (all guests, snapshot mode)"
if pvesh get /cluster/backup --output-format json | grep -q "\"storage\":\"$STORE_ID\""; then
  echo "   a backup job to '$STORE_ID' already exists, skipping"
else
  pvesh create /cluster/backup --schedule "02:00" --storage "$STORE_ID" --all 1 \
    --mode snapshot --enabled 1 --notes-template "{{guestname}}" --comment "nightly to PBS"
fi

echo "== 6/6 Running first backup now (this is the long part)"
vzdump --all --storage "$STORE_ID" --mode snapshot --notes-template "{{guestname}}"

echo "== DONE. Log: $LOG"
pvesm list "$STORE_ID" | tail -n +1
