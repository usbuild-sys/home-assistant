# Home Assistant – Viessmann boiler (Optolink) and hydronic heating

Local, cloud-free monitoring of a **Viessmann Vitodens 200-W (B2HA)** gas boiler with a
**Vitotronic 200 HO1B** controller in **Home Assistant**, using the **Optolink** interface
(the CP2102 USB cable from a Vitoconnect 100 OPTO1) and **MQTT**.

Keywords: Viessmann, Vitodens, Vitotronic 200, HO1B, 20CB, Optolink, P300 / VS2,
Vitoconnect OPTO1, optolink2mqtt, MQTT, Home Assistant, ESPHome, boiler, hydronic heating.

## Projects
- [`boiler1-optolink/`](boiler1-optolink/) – optolink2mqtt config with **verified register
  addresses** (outdoor, boiler water, room setpoint, operating mode, burner, modulation, pump, fault),
  a raw register scanner script, and a Vitotronic-style Home Assistant dashboard card (no HACS).
