#!/bin/sh
#
# Keeps this repository on top of the original product repository (nexwall/firewall-msp): every change of this fork is a
# commit on top of upstream main, so a sync is a rebase onto the newest upstream main.
#
#   scripts/sync-upstream.sh            fetch upstream main and rebase onto it
#   UPSTREAM_URL=git@github.com:nexwall/firewall-msp.git scripts/sync-upstream.sh
#
# On the build server the upstream is the local checkout /root/firewall-msp (update it first: git -C /root/firewall-msp pull).
# A conflict stops the rebase: resolve it (git status), `git rebase --continue`, then re-run the checks listed at the end.
set -eu
cd "$(dirname "$0")/.."
UP="${UPSTREAM_URL:-/root/firewall-msp}"
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UP"
[ -z "$(git status --porcelain)" ] || { echo "working tree is not clean: commit or stash first" >&2; exit 1; }
git fetch -q upstream main
OLD="$(git merge-base HEAD upstream/main)"
NEW="$(git rev-parse upstream/main)"
if [ "$OLD" = "$NEW" ]; then echo "already on the newest upstream main ($(git rev-parse --short "$NEW"))"; exit 0; fi
git tag -f "pre-sync-$(date +%Y%m%d-%H%M)" >/dev/null
echo "upstream: $(git rev-parse --short "$OLD") -> $(git rev-parse --short "$NEW") ($(git rev-list --count "$OLD..$NEW") commits)"
MINE="$(mktemp)"
git diff --name-only "$OLD" HEAD | sort > "$MINE"
echo "files of this fork that upstream also changed (the likely conflicts):"
git diff --name-only "$OLD" "$NEW" | sort | comm -12 - "$MINE" | sed 's/^/  /'
rm -f "$MINE"
git rebase upstream/main || { echo "CONFLICT: resolve, git rebase --continue, then do the checks below" >&2; exit 2; }
cat <<EOT
Synced. Now check:
  1. packages/nexwall-{license,webd,netify-plugins,snort-plugins,ns-ui}/Makefile: upstream bumped a version? The ARM pins are per architecture
     (VENDOR_CORE_VERSION_aarch64, WEBD_FEED_SHA256_aarch64, ...): bump them only after an aarch64 build of that version exists in vendor-local/.
  2. netifyd or snort3 changed upstream? The ARM plugins must be rebuilt against them (BUILD_INFO).
  3. config/*.conf got new symbols? Build once and review config/targets/mediatek_filogic.expected-drops.
  4. Update NETHSECURITY_VERSION in build.conf.defaults (it follows upstream) and FORK-CHANGES.md.
EOT
