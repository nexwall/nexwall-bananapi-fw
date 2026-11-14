#!/usr/bin/env sh

#
# Copyright (C) 2025 Nethesis S.r.l.
# SPDX-License-Identifier: GPL-2.0-only
#
# Test-track variant: apply every patch, report all failures at the end.

failed=""
for patch in $(find patches/ -type f -name "*.patch" | sort); do
    dir_name=$(dirname "$patch")
    dir_name=${dir_name#"patches/"}
    if ! patch -d "$dir_name" -F 2 -p 1 < "$patch"; then
        failed="$failed $patch"
    fi
done
if [ -n "$failed" ]; then
    echo "PATCHES FAILED:$failed"
    exit 1
fi
