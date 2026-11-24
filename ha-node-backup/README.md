# ha-node → Proxmox Backup Server

`setup-pbs-backup.sh` – run on ha-node (172.17.1.44) as root. It:
1. checks PBS (172.17.1.80:8007) is reachable, asks for the PBS password once,
2. reads the PBS certificate fingerprint and lists datastores,
3. adds PBS storage `pbs` to ha-node,
4. creates a nightly 02:00 snapshot backup job for all guests (HA VM 100, optolink LXC 101),
5. runs the first backup immediately, logging to /root/pbs-setup-<date>.log.

The existing PBS → B2 sync (03:00) picks these backups up automatically. Don't add B2 verify jobs.
Re-running is safe: existing storage / job are skipped.
