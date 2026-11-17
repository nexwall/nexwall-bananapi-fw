# Banana Pi BPI-R4 Pro 4E and 8X (experimental)

Status: experimental community build. Not for production. Not validated on real hardware (ports, switch and 10G links unverified).

## Why a separate branch
The R4 Pro is supported only by OpenWrt main (Linux kernel 6.18). The other Filogic boards use the OpenWrt 25.12 release (kernel 6.12).
Branch `r4pro-main-26.2.1` is the release tree (`main`) plus the changes below; the five-board images are built from `main`.

## Differences from the 25.12 build
- Core pinned to OpenWrt main commit `593608fbdae9`; package feeds stay on `openwrt-25.12`.
- Patches adapted or dropped for main (base-files banner, openvpn, strongswan dpd); host Python built without `_curses`.
- Packages whose user/group ids clash with main's core are dropped (sane-backends, tvheadend).
- Image Builder is off: with it main builds the kernel of every Filogic board and stops on missing bootloaders.
- The traffic-engine and Snort plugins are rebuilt against main's `libubox` and `libubus` (soname change) and pinned as
  `nexwall-netify-plugins_1.0.4-main_aarch64` and `nexwall-snort-plugins_1.0.1-main_aarch64`. Rebuild them whenever netifyd, snort3
  or main's libraries change.

## Pins (same as the 26.2.1 five-board set unless noted)
| Component | Version |
|---|---|
| License core | 1.11.0 aarch64 |
| Web interface | 3.2.1 |
| Web Protection | 0.10.1 |
| Web daemon | 1.5.0 aarch64 |
| Traffic-engine plugins | 1.0.4-main (differs) |
| Snort plugins | 1.0.1-main (differs) |

## Build
```
PROFILE=bananapi_bpi-r4-pro-4e ./build-nexwall.sh      # or bananapi_bpi-r4-pro-8x
```
Needs the vendor tarballs in `vendor-local/` and about 65 GB of free disk for the first build on a new base.

## Hardware notes
- 4E: MT7988A, internal 2.5G PHY, MxL862 switch. 8X: MT7988A, Aeonsemi 10G PHY, MxL862 switch.
- Switch driver (`kmod-dsa-mxl862xx`) and the device trees come from OpenWrt main.
