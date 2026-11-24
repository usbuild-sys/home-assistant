# Boiler 1 – Viessmann Optolink → MQTT → Home Assistant

Vitodens 200-W B2HA 19, Vitotronic 200 HO1B (device ID 20CB), read locally over Optolink
using the CP2102 cable from the Vitoconnect 100 OPTO1.

## Setup
- Host: LXC 101 `optolink` on Proxmox `ha-node` (172.17.1.44); USB passed through by its `/dev/serial/by-id/` path.
- Software: [viessmann-optolink2mqtt](https://github.com/f18m/viessmann-optolink2mqtt) 1.2.7 in venv `/opt/optolink2mqtt`.
- MQTT: Mosquitto on HA (172.17.1.125:1883), HA user `optolink`; password only in `/etc/optolink2mqtt/env` (not in git).
- Protocol: P300/VS2, 4800 8E2.

## Verified registers
| Name | Addr | Len | Scale | Notes |
|---|---|---|---|---|
| Outdoor temperature | 0x5525 | 2 | 0.1 signed | matches boiler display |
| Boiler water temperature | 0x0810 | 2 | 0.1 | matches boiler display |
| Room set temperature (normal, A1M1) | 0x2306 | 1 | 1 | 13 °C = 55 °F on display |
| Room set reduced (A1M1) | 0x2307 | 1 | 1 | read 3 °C; not polled |
| Operating mode | 0x2323 | 1 | enum | 0 Off/standby, 1 DHW only, 2 Heating+DHW (both states verified) |
| Current mode | 0x2500 | 1 | enum | 0 Off, 1 Reduced, 2 Normal, 3 Permanent normal |
| Fault (collective) | 0x0A82 | 1 | 0/1 | |
| Circuit pump A1M1 | 0x2906 | 1 | 0/1 | |
| Internal pump | 0x7660 | 1 | 0/1 | read OK; not polled |
| Burner | 0x55D3 | 1 | >0 = on | 0x24 running, 00 off |
| Burner modulation | 0xA38F | 2 | 0.1 % (assumed) | 309 running, 0 off; scale not checked vs boiler |
| Boiler setpoint | 0x555A | 2 | 0.1 | works, not polled |

Not working: 0x2510 (frost protection) – boiler returns an error frame.

## HA dashboard
`boiler1_card.yaml` – Picture elements card (no HACS) styled like the Vitotronic screen.
Entities: `sensor.vitodens_boiler_1_*`, `binary_sensor.vitodens_boiler_1_*`.

## Gotchas
- HA discovery topics allow only `[a-zA-Z0-9_-]`; device name with spaces is silently ignored.
- Stop the service before running `vitoscan.py` (serial port is exclusive).
- Long pastes into the Proxmox web console get scrambled; use SSH and keep heredocs short.
