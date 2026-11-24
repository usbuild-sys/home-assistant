# Panel Test – Waveshare ESP32-S3-Touch-LCD-7 (ESPHome + LVGL)

Mechanical-room wall panel at 192.168.99.152 (IoT subnet, `use_address` because mDNS doesn't cross subnets).
Hardware package: `agillis/esphome-modular-lvgl-buttons` (waveshare-esp32-s3-touch-lcd-7).

## Pages (swipe left / right)
1. **Heating gauges** – Bathrooms & Kitchen floors (supply / mix / return) and radiator supply / return,
   from the DS18B20 pipe sensors on the `heating-zones-sensors` ESP32. Blue / amber / red zones.
2. **Boiler 1** – Vitotronic-style screen fed from the Optolink sensors (see `../boiler1-optolink`):
   outdoor, room set, boiler temperature, operating mode text, and live icons:
   tap/radiator = mode, sun = normal mode, orange flame + % = burner modulation > 0, red alert = fault.

## Notes
- Icons: Material Design Icons webfont, glyphs F1B29 faucet, F0438 radiator, F05A8 sun, F0238 fire, F0026 alert.
- Flame is driven by `sensor.vitodens_boiler_1_burner_modulation` (> 0), not the Burner binary_sensor:
  the panel never reacted to the binary_sensor going from unknown to on.
- Swipe uses `on_swipe_left` / `on_swipe_right` page triggers + `lvgl.page.next/previous` (MOVE_LEFT/RIGHT).
- Secrets needed in ESPHome `secrets.yaml`: `panel_test_api_key`, `wifi_ssid`, `wifi_password`, `ap_password`, `ota_password`.
  (The live config in ESPHome Builder has the API key inline; it is replaced with a secret here.)
