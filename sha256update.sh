#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# Regenerate and verify SHA256SUMS for the distributable project files.

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
MANIFEST="$PROJECT_DIR/SHA256SUMS"

if (( $# != 0 )); then
    echo 'Usage: bash sha256update.sh' >&2
    exit 2
fi

for dependency in find sort sha256sum mktemp chmod; do
    command -v "$dependency" >/dev/null || {
        echo "Missing dependency: $dependency" >&2
        exit 1
    }
done

manifest_tmp="$(mktemp "$PROJECT_DIR/.SHA256SUMS.tmp.XXXXXX")"
cleanup() {
    rm -f -- "$manifest_tmp"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' HUP TERM

cd -- "$PROJECT_DIR"

find . -type f \
    ! -path './.git/*' \
    ! -path './SHA256SUMS' \
    ! -path './config/AllDayLong-2026.gnome.xml' \
    ! -path './last-status.log' \
    ! -name '.SHA256SUMS.tmp.*' \
    -print0 \
    | sort -z \
    | while IFS= read -r -d '' file; do
        sha256sum -- "${file#./}"
    done > "$manifest_tmp"

if [[ ! -s "$manifest_tmp" ]]; then
    echo 'No files found; SHA256SUMS was not changed.' >&2
    exit 1
fi

if [[ -e "$MANIFEST" ]]; then
    chmod --reference="$MANIFEST" "$manifest_tmp"
else
    chmod 0644 "$manifest_tmp"
fi

mv -- "$manifest_tmp" "$MANIFEST"
trap - EXIT HUP INT TERM

sha256sum --check "$MANIFEST"
echo "Updated $MANIFEST"
