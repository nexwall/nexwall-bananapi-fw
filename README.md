# Nexwall Firewall for Banana Pi (MediaTek Filogic)

Build of Nexwall Firewall (an OpenWrt-based firewall distribution) for Banana Pi boards with a MediaTek Filogic SoC.
Derived from `nexwall/firewall-msp` (version in `build.conf.defaults`); the changes against it are listed in `FORK-CHANGES.md`.

| Board | Profile (`PROFILE=`) | SoC | Notes |
|---|---|---|---|
| Banana Pi BPI-R3 | `bananapi_bpi-r3` (default) | MT7986 | 2 GiB RAM, 8 GiB eMMC |
| Banana Pi BPI-R3 Mini | `bananapi_bpi-r3-mini` | MT7986A | 2 GiB RAM |
| Banana Pi BPI-R4 Lite | `bananapi_bpi-r4-lite` | MT7987A | 2 GiB RAM, 8 GiB eMMC |
| Banana Pi BPI-R4 | `bananapi_bpi-r4` | MT7988A | 4 GiB RAM, 8 GiB eMMC |
| Banana Pi BPI-R4 (2.5GE variant) | `bananapi_bpi-r4-poe` | MT7988A | |

The OpenWrt One has its own repository: `nexwall/nexwall-openwrt-one-fw`.

All boards share one target (`mediatek/filogic`) and one package architecture (`aarch64_cortex-a53`): the packages are built
once and the board profile only selects the image. Boot, partitions and mounts are the ones of the upstream OpenWrt images
(this repository does not change them). Data (threat lists, web categories, logs, proxy cache) belongs on an NVMe disk,
mounted by the storage package exactly as on the x86 firewall.

## Build

```
podman, a user without root, 8 GiB RAM or more, 60 GiB of disk or more
PROFILE=bananapi_bpi-r4 ./build-nexwall.sh
```

`TARGET` defaults to `mediatek_filogic`. The images are written to `bin/targets/mediatek/filogic/`. Set `MAKE_JOBS` lower on
hosts with little RAM (the LLVM build step is the heaviest). Package signing keys (`private-key.pem`, `public-key.pem`) are
not part of the repository.

## Vendor binaries

The license core, the web protection service, the web interface and the traffic-engine and IPS plugins are published as
binaries; the recipes pin one SHA-256 per architecture and stop the build when an enabled component has no pin for
`aarch64`. Without them the image is a community build for that component. See `docs/BOARDS.md`.

## License

Same as `nexwall/firewall-msp` (see `LICENSE` and `NOTICE.md`).

## Relation to `nexwall/firewall-msp`

`firewall-msp` is the original and stays the source of truth. This repository is `firewall-msp` plus a short series of commits
(Filogic target, board profiles, per-architecture vendor pins, Wi-Fi stack, WAN fallback). To follow a new upstream version run
`scripts/sync-upstream.sh`: it fetches upstream main and rebases the series onto it, then lists what to check (vendor pins, plugin
ABI, new kernel symbols). Never edit upstream files for a board-specific reason when a profile or a new file will do: it keeps the
rebase small.
