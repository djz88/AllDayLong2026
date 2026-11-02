<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# GNOME — official GSettings and XML slideshow

GNOME supports dynamic wallpapers through XML. The supplied `AllDayLong-2026.xml` defines a fixed 24-hour cycle with **smooth transitions**. Use GSettings (`gsettings`) to configure the user background, not the legacy GConf system.

## Recommended — installation script

1. Extract the ZIP archive and open a terminal in the `AllDayLong-2026/` directory.
2. Run the installer without `sudo`:

```bash
bash ./install-gnome.sh
```

The installer does not copy anything. It verifies the eight PNG files and the source XML in the package directory, generates a runtime `AllDayLong-2026.gnome.xml` in `config/` with absolute paths to the local images, and configures both GSettings keys to use that file.

Keep the extracted directory in a private user-owned location that other users cannot modify. Do not move or delete it afterward. If you move it, rerun the installer from the new location.

## Manual setup — without the installation script

1. Keep the eight PNG files in `images/` and the source XML in `config/`.
2. Create a runtime copy next to the source XML and replace every path in the `<file>`, `<from>`, and `<to>` elements with an absolute path to the corresponding PNG. These values are file-system paths, not `file://` URIs.
3. Run the following commands in a GNOME user session:

```bash
URI="$(python3 -c 'from pathlib import Path; print(Path("config/AllDayLong-2026.gnome.xml").resolve().as_uri())')"
gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
```

Run the commands from the package root. **Both** keys must point to the runtime XML; otherwise, switching between light and dark appearance may interrupt the all-day cycle.

## Verification

```bash
gsettings get org.gnome.desktop.background picture-uri
gsettings get org.gnome.desktop.background picture-uri-dark
```

Both outputs should contain `AllDayLong-2026.gnome.xml`. Changes to the XML itself may not be loaded immediately while the wallpaper is already active; setting the URI again can force a reload.

## Reverting

Choose a different image in Settings → Appearance → Background, or reset the individual keys to their system defaults:

```bash
gsettings reset org.gnome.desktop.background picture-uri
gsettings reset org.gnome.desktop.background picture-uri-dark
```

Resetting restores the default values, not an older custom user value. After resetting, you may delete the generated `config/AllDayLong-2026.gnome.xml`.

**Official documentation:**

- [GNOME GSettings configuration](https://help.gnome.org/system-admin-guide/gsettings-browse.html)
- [GNOME desktop background](https://help.gnome.org/system-admin-guide/desktop-background.html)
- [GNOME graphical background settings](https://help.gnome.org/gnome-help/look-background.html)
- [Ubuntu Community Help: XML slideshows](https://help.ubuntu.com/community/SlideshowWallpapers)
