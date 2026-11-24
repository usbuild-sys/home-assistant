#!/bin/sh
# optolink2mqtt 1.2.7 bug: schema accepts ha_discovery.value_template but it is never sent
# in the HA discovery message, so the Burner binary_sensor shows "Unknown".
# Re-run after every `pip install -U viessmann-optolink2mqtt`.
F=/opt/optolink2mqtt/lib/python3.11/site-packages/optolink2mqtt/optolinkvs2_register.py
grep -q '"value_template",' "$F" || sed -i 's/^\(\s*\)"optimistic",/\1"optimistic",\n\1"value_template",/' "$F"
grep -n '"value_template",' "$F" && systemctl restart optolink2mqtt
