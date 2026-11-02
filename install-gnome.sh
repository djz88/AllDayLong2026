#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
IMAGE_SOURCE="$SOURCE_DIR/images"
XML_SOURCE="$SOURCE_DIR/config/AllDayLong-2026.xml"
XML_RUNTIME="$SOURCE_DIR/config/AllDayLong-2026.gnome.xml"

if [[ "$(id -u)" -eq 0 ]]; then
  echo 'Do not run this script as root (sudo); it configures the current user wallpaper.' >&2
  exit 1
fi

if (( $# != 0 )); then
  echo 'This installer does not accept a target directory; it uses files in the extracted package.' >&2
  exit 1
fi

for n in 01 02 03 04 05 06 07 08; do
  [[ -f "$IMAGE_SOURCE/$n.png" ]] || { echo "Missing image: $IMAGE_SOURCE/$n.png" >&2; exit 1; }
done
[[ -f "$XML_SOURCE" ]] || { echo "Missing XML: $XML_SOURCE" >&2; exit 1; }
command -v python3 >/dev/null || { echo 'Python 3 is required.' >&2; exit 1; }
command -v gsettings >/dev/null || { echo 'gsettings is required (this installer is for GNOME).' >&2; exit 1; }
gsettings get org.gnome.desktop.background picture-uri >/dev/null 2>&1 || { echo 'The org.gnome.desktop.background picture-uri key is unavailable.' >&2; exit 1; }
gsettings get org.gnome.desktop.background picture-uri-dark >/dev/null 2>&1 || { echo 'The org.gnome.desktop.background picture-uri-dark key is unavailable.' >&2; exit 1; }

python3 - "$XML_SOURCE" "$XML_RUNTIME" "$IMAGE_SOURCE" <<'PYXML'
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

src, dst, image_dir = map(Path, sys.argv[1:])
xml = ET.parse(src)
root = xml.getroot()
if root.tag != 'background':
    raise ValueError('Invalid XML format')

expected = {f'{n:02d}.png' for n in range(1, 9)}
duration = 0.0
for item in root:
    if item.tag not in ('static', 'transition'):
        continue
    duration += float(item.findtext('duration'))
    for tag in ('file', 'from', 'to'):
        element = item.find(tag)
        if element is None:
            continue
        name = Path(element.text.strip()).name
        if name not in expected:
            raise ValueError(f'Unexpected file in XML: {name}')
        element.text = str((image_dir / name).resolve(strict=True))

if abs(duration - 86400.0) > 0.01:
    raise ValueError(f'XML duration is not 24 hours: {duration} s')

xml.write(dst, encoding='utf-8', xml_declaration=True)
PYXML

URI="$(python3 - "$XML_RUNTIME" <<'PYURI'
from pathlib import Path
import sys
print(Path(sys.argv[1]).resolve(strict=True).as_uri())
PYURI
)"

gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"

echo "GNOME: configured directly from $SOURCE_DIR"
echo "Both GNOME keys use: $URI"
echo 'Do not move or delete this directory; rerun the installer after moving it.'
