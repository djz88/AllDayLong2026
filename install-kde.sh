#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# AllDayLong 2026 – KDE Plasma 6
# Install: bash install-kde.sh
# Apply:   bash install-kde.sh --apply
# Remove:  bash install-kde.sh --uninstall

set -euo pipefail

NAME="alldaylong-kde"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"
IMAGE_DIR="$SCRIPT_DIR/images"
XML_CONFIG="$SCRIPT_DIR/config/AllDayLong-2026.xml"
UNIT_DIR="$HOME/.config/systemd/user"
AUTOSTART_DIR="$HOME/.config/autostart"
SERVICE="$UNIT_DIR/$NAME.service"
TIMER="$UNIT_DIR/$NAME.timer"
AUTOSTART="$AUTOSTART_DIR/$NAME.desktop"

if (( EUID == 0 )); then
    echo 'Do not run this script as root.' >&2
    exit 1
fi

validate_package() {
    python3 - "$XML_CONFIG" "$IMAGE_DIR" <<'PY'
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

xml_path, image_dir = map(Path, sys.argv[1:])
if not xml_path.is_file():
    raise SystemExit(f'Missing XML: {xml_path}')

root = ET.parse(xml_path).getroot()
if root.tag != 'background':
    raise SystemExit('Invalid XML format')

expected = {f'{n:02d}.png' for n in range(1, 9)}
seen = set()
duration = 0.0
for item in root:
    if item.tag not in ('static', 'transition'):
        continue
    value = float(item.findtext('duration'))
    if value <= 0:
        raise SystemExit('XML contains an invalid interval duration')
    duration += value
    for tag in ('file', 'from', 'to'):
        element = item.find(tag)
        if element is None:
            continue
        name = Path(element.text.strip()).name
        if name not in expected:
            raise SystemExit(f'Unexpected file in XML: {name}')
        seen.add(name)

if abs(duration - 86400.0) > 0.01:
    raise SystemExit(f'XML must describe exactly 24 hours; it contains {duration} s')
if seen != expected:
    missing = ', '.join(sorted(expected - seen))
    raise SystemExit(f'XML does not reference every image: {missing}')
for name in sorted(expected):
    if not (image_dir / name).is_file():
        raise SystemExit(f'Missing image: {image_dir / name}')
PY
}

current_image() {
    python3 - "$XML_CONFIG" <<'PY'
from datetime import datetime
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
start = root.find('starttime')
start_seconds = (
    int(start.findtext('hour')) * 3600
    + int(start.findtext('minute')) * 60
    + int(start.findtext('second'))
)
now = datetime.now()
elapsed = (now.hour * 3600 + now.minute * 60 + now.second - start_seconds) % 86400
cursor = 0.0

for item in root:
    if item.tag not in ('static', 'transition'):
        continue
    duration = float(item.findtext('duration'))
    if cursor <= elapsed < cursor + duration:
        if item.tag == 'static':
            value = item.findtext('file')
        elif elapsed < cursor + duration / 2:
            value = item.findtext('from')
        else:
            value = item.findtext('to')
        print(Path(value.strip()).name)
        break
    cursor += duration
else:
    raise SystemExit('No image was found in the XML for the current time')
PY
}

calendar_lines() {
    python3 - "$XML_CONFIG" <<'PY'
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
start = root.find('starttime')
seconds = (
    int(start.findtext('hour')) * 3600
    + int(start.findtext('minute')) * 60
    + int(start.findtext('second'))
)

for item in root:
    if item.tag not in ('static', 'transition'):
        continue
    duration = float(item.findtext('duration'))
    if item.tag == 'transition':
        midpoint = int(round((seconds + duration / 2) % 86400))
        hour, rest = divmod(midpoint, 3600)
        minute, second = divmod(rest, 60)
        print(f'OnCalendar=*-*-* {hour:02d}:{minute:02d}:{second:02d}')
    seconds += duration
PY
}

systemd_quote() {
    python3 - "$1" <<'PY'
import sys
value = sys.argv[1].replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%')
print(f'"{value}"')
PY
}

desktop_quote() {
    python3 - "$1" <<'PY'
import sys
value = sys.argv[1].replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%')
print(f'"{value}"')
PY
}

apply_wallpaper() {
    command -v python3 >/dev/null || { echo 'Python 3 is required.' >&2; exit 1; }
    command -v kwriteconfig6 >/dev/null || { echo 'kwriteconfig6 is required.' >&2; exit 1; }
    validate_package

    local name file uri js dbus_cmd attempt
    name="$(current_image)"
    file="$IMAGE_DIR/$name"
    uri="$(python3 - "$file" <<'PY'
from pathlib import Path
import sys
print(Path(sys.argv[1]).resolve(strict=True).as_uri())
PY
)"
    js="$(python3 - "$uri" <<'PY'
import json
import sys

uri = json.dumps(sys.argv[1])
print(
    "var ds=desktops();"
    "for(var i=0;i<ds.length;i++){"
    "var d=ds[i];"
    "d.wallpaperPlugin='org.kde.image';"
    "d.currentConfigGroup=['Wallpaper','org.kde.image','General'];"
    "d.writeConfig('Image'," + uri + ");"
    "}"
)
PY
)"

    kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.image
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "$uri"
    kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key PreviewImage "$uri"

    if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "/run/user/$(id -u)/bus" ]]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    fi

    dbus_cmd=''
    for dbus_cmd in qdbus6 qdbus-qt6 qdbus; do
        if command -v "$dbus_cmd" >/dev/null 2>&1; then
            break
        fi
        dbus_cmd=''
    done
    if [[ -z "$dbus_cmd" ]]; then
        for candidate in /usr/lib/qt6/bin/qdbus6 /usr/lib64/qt6/bin/qdbus6; do
            if [[ -x "$candidate" ]]; then
                dbus_cmd="$candidate"
                break
            fi
        done
    fi

    for attempt in {1..12}; do
        if [[ -n "$dbus_cmd" ]]; then
            if "$dbus_cmd" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$js" >/dev/null 2>&1; then
                echo "AllDayLong: $name (desktop and lock screen)"
                return 0
            fi
        elif command -v gdbus >/dev/null 2>&1; then
            if gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell --method org.kde.PlasmaShell.evaluateScript "$js" >/dev/null 2>&1; then
                echo "AllDayLong: $name (desktop and lock screen)"
                return 0
            fi
        else
            echo 'qdbus6 or gdbus is required.' >&2
            return 1
        fi
        sleep 2
    done

    echo 'Unable to communicate with KDE plasmashell.' >&2
    return 1
}

uninstall() {
    systemctl --user disable --now "$NAME.timer" 2>/dev/null || true
    rm -f -- "$SERVICE" "$TIMER" "$AUTOSTART"
    systemctl --user daemon-reload
    echo 'AllDayLong KDE: timer, service, and autostart entry removed.'
    echo "Package retained unchanged in $SCRIPT_DIR"
}

install() {
    local command bash_path quoted_bash quoted_script desktop_bash desktop_script
    for command in python3 systemctl kwriteconfig6; do
        command -v "$command" >/dev/null || { echo "Missing dependency: $command" >&2; exit 1; }
    done
    validate_package
    mkdir -p -- "$UNIT_DIR" "$AUTOSTART_DIR"

    bash_path="$(command -v bash)"
    quoted_bash="$(systemd_quote "$bash_path")"
    quoted_script="$(systemd_quote "$SCRIPT_PATH")"
    desktop_bash="$(desktop_quote "$bash_path")"
    desktop_script="$(desktop_quote "$SCRIPT_PATH")"

    cat > "$SERVICE" <<SERVICE_UNIT
[Unit]
Description=AllDayLong KDE desktop and lock screen

[Service]
Type=oneshot
ExecStart=$quoted_bash $quoted_script --apply
SERVICE_UNIT

    {
        cat <<'TIMER_HEADER'
[Unit]
Description=AllDayLong KDE wallpaper schedule

[Timer]
Unit=alldaylong-kde.service
TIMER_HEADER
        calendar_lines
        cat <<'TIMER_FOOTER'
OnStartupSec=20s
AccuracySec=1s
Persistent=true

[Install]
WantedBy=timers.target
TIMER_FOOTER
    } > "$TIMER"

    cat > "$AUTOSTART" <<DESKTOP_FILE
[Desktop Entry]
Type=Application
Name=AllDayLong KDE
Comment=Time-based desktop and lock screen wallpaper
Exec=$desktop_bash $desktop_script --apply
OnlyShowIn=KDE;
Terminal=false
DESKTOP_FILE

    systemctl --user daemon-reload
    systemctl --user enable --now "$NAME.timer"

    if [[ "${XDG_CURRENT_DESKTOP:-}" == *KDE* || "${XDG_CURRENT_DESKTOP:-}" == *Plasma* ]]; then
        apply_wallpaper || echo 'The wallpaper will be set after the next KDE login.'
    fi

    echo 'AllDayLong KDE installed without copying the package.'
    echo "Source directory: $SCRIPT_DIR"
    echo "Timer: systemctl --user list-timers $NAME.timer"
    echo "Manual synchronization: bash \"$SCRIPT_PATH\" --apply"
    echo "Uninstall: bash \"$SCRIPT_PATH\" --uninstall"
    echo 'Do not move or delete this directory; rerun the installer after moving it.'
}

case "${1:-}" in
    --apply)
        (( $# == 1 )) || { echo 'The --apply option cannot be combined with other arguments.' >&2; exit 1; }
        apply_wallpaper
        ;;
    --uninstall)
        (( $# == 1 )) || { echo 'The --uninstall option cannot be combined with other arguments.' >&2; exit 1; }
        uninstall
        ;;
    '')
        install
        ;;
    *)
        echo 'Usage: bash install-kde.sh [--apply|--uninstall]' >&2
        exit 1
        ;;
esac
