<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Wi-Fi Adapter Lab

Use this lab only on your own networks and hardware.

## First Task

Identify the adapter before assuming it works:

```sh
lsusb
usb-devices
dmesg | tail -80
iw dev
ip link
```

## Notes To Record

- Adapter model and revision.
- USB vendor/product ID.
- Chipset.
- Driver/module.
- Whether desktop Linux supports it.
- Whether Android OTG powers it.
- Whether Arch chroot can see it.
- Whether monitor mode works in your own lab.

## Private Data

Wireless captures, BSSIDs, client MACs, and GPS-like location hints are private.

