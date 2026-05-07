<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Wi-Fi Project

Goal: learn the new USB Wi-Fi adapter safely and connect the results to the NetHunter kernel roadmap.

## First Milestone

Identify the chipset before assuming support.

```sh
lsusb
usb-devices
dmesg | tail -80
iw dev
ip link
```

## Paths

```text
lab: /workspace/04-labs/wifi-adapter
docs: /workspace/06-docs/wifi
artifacts: /workspace/07-artifacts/reports
```

