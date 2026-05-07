<!-- NH_SETUP_VERSION: 2.0 default -->
<!-- Profile: Arch ARM64 v2.0 default; Kali ARM64 v2.0 default -->

# Wi-Fi Adapter Project Track

Default profile: `Arch ARM64 v2.0 (default)` with `Kali ARM64 v2.0 (default)` reserved for authorized NetHunter workflows.

Date: 2026-05-07

Scope: personal learning lab for the OnePlus 7 Pro, Arch Linux chroot, and future NetHunter setup. Use only your own access points, lab networks, and hardware you control or have explicit written permission to test.

## Current Assumptions

- The adapter is still unopened, so the chipset is unknown.
- The phone target is OnePlus 7 Pro GM1911 on Android 16 with Arch ARM64 already installed.
- Arch currently runs inside the Android kernel, so USB Wi-Fi behavior depends on Android kernel support, USB OTG power, and loaded modules.
- Full NetHunter Wi-Fi injection requires a NetHunter-capable custom kernel. NetHunter Lite/rootless are useful for tools, but official Kali docs distinguish full NetHunter as the edition with Wi-Fi injection support.

## Adapter Keep/Return Decision

Before committing to the adapter, identify the chipset:

```sh
lsusb
usb-devices
dmesg | tail -80
iw dev
ip link
```

Preferred chipsets for this project:

- Best beginner path: `MT7612U` or `MT7610U`, native `mt76` family on Linux and listed by Kali NetHunter docs.
- Strong 2.4 GHz learning path: `AR9271`, native `ath9k_htc`, very mature.
- Good if supported by kernel/driver: `RTL8812AU`, `RTL8814AU`, `RTL8811AU`.
- Avoid if you can return it: adapters with vague "Linux compatible" marketing and no chipset, or chipsets that require unstable out-of-tree drivers on Android.

Also test power early. Kali NetHunter docs warn that Android OTG power can be limited and some adapters may need a powered OTG/Y-cable.

## Project 1: Adapter Bring-Up And Evidence Log

Goal: identify the adapter, driver, power behavior, and whether it belongs in our long-term kit.

Beginner tasks:

- Photograph/record the model, revision, FCC ID, and chipset if listed.
- Test on desktop Linux first with `lsusb`, `dmesg`, `iw dev`, and `ip link`.
- Test on the phone through OTG from Android root, then from Arch chroot.
- Record whether the adapter lights up, enumerates, gets a driver, and exposes a wireless interface.

Arch/NetHunter angle:

- Create `/workspace/notes/wifi-adapter-lab.md`.
- Record USB IDs, kernel messages, module names, and power symptoms.
- Decide keep, return, or reserve for desktop-only use.

Done when:

- You know the exact chipset.
- You know whether the phone powers it reliably.
- You know whether monitor mode is possible on desktop and likely possible on phone.

## Project 2: Passive Monitor Mode Lab

Goal: learn 802.11 observation without touching other people's networks.

Beginner tasks:

- Put the adapter in monitor mode on desktop first.
- Observe only metadata: channels, signal strength, BSSID/SSID visibility, beacon interval, encryption type.
- Repeat inside Arch if the phone kernel exposes the adapter.
- Save short captures from your own lab AP only.

Allowed lab scope:

- Your own router.
- A spare travel router.
- A phone hotspot you own.
- No deauthentication, password attacks, or traffic capture from third-party networks.

Done when:

- You can explain managed mode versus monitor mode.
- You can map your own AP on 2.4 GHz and 5 GHz.
- You have a clean note showing commands, interface names, and observations.

## Project 3: Kismet Passive Sensor

Goal: turn the phone plus adapter into a passive wireless sensor.

Why this matters:

- Kismet's Linux Wi-Fi source captures from monitor-mode interfaces and supports channel definitions for 2.4 GHz, 5 GHz, and 6 GHz where hardware supports it.
- This is a good beginner-friendly project because it teaches capture sources, channels, logs, GPS/privacy handling, and long-running services.

Beginner tasks:

- Run Kismet on desktop first.
- Add one Wi-Fi source and name it clearly.
- Move to Arch/NetHunter after the adapter is stable.
- Store logs under `/workspace/projects/wifi-lab/kismet/`.

Privacy rules:

- Do not publish raw Kismet logs.
- Treat BSSIDs, client MACs, SSIDs, and GPS coordinates as sensitive.
- Use this as a personal local lab, not public recon.

Done when:

- Kismet sees your adapter.
- You can start/stop it cleanly.
- You can export a small report from your own lab area.

## Project 4: Own-Network Performance And Coverage Map

Goal: use the adapter for normal engineering measurements, not attacks.

Beginner tasks:

- Compare internal Wi-Fi, USB adapter, and phone hotspot performance.
- Use `iperf3` between your desktop and a device on your own LAN.
- Record channel, band, RSSI, link rate, packet loss, and distance.
- Build a simple coverage map for your home/lab.

Arch/Android angle:

- Run the client from Arch if networking is stable.
- Keep the dataset under `/workspace/projects/wifi-lab/coverage/`.
- Later, build a small web dashboard from the measurements.

Done when:

- You know which channels and bands are reliable in your space.
- You can make evidence-based antenna/placement decisions.
- You have data that helps future NetHunter tests avoid false driver blame.

## Project 5: NetHunter Kernel Capability Matrix

Goal: connect Wi-Fi adapter learning to the custom kernel roadmap.

Beginner-to-advanced tasks:

- List kernel modules needed for your chipset.
- Compare current Android kernel support against NetHunter-supported chipsets.
- Record whether `cfg80211`, `mac80211`, chipset driver, USB host, and OTG power are available.
- Add a future `nh-wifi-check` script that prints adapter, driver, mode support, and missing kernel features.

Done when:

- You can state exactly what the custom kernel must enable for your adapter.
- You have a test checklist for every future kernel build.
- You can separate "driver missing" from "power problem" from "userspace tool problem".

## Recommended Start Order

1. Project 1: Adapter Bring-Up And Evidence Log.
2. Project 2: Passive Monitor Mode Lab.
3. Project 4: Own-Network Performance And Coverage Map.
4. Project 3: Kismet Passive Sensor.
5. Project 5: NetHunter Kernel Capability Matrix.

## Source Notes

- Kali NetHunter overview: https://www.kali.org/docs/nethunter/
- Kali NetHunter wireless cards: https://www.kali.org/docs/nethunter/wireless-cards/
- Kismet Linux Wi-Fi datasource: https://www.kismetwireless.net/docs/readme/datasources/wifi-linux/
- Aircrack-ng RTL8812AU driver reference: https://github.com/aircrack-ng/rtl8812au
