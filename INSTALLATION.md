<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# AllDayLong 2026 – Installation

AllDayLong 2026 is a set of eight timed wallpapers showing the same scene changing throughout the day.

Supported systems:

- GNOME
- KDE Plasma 6
- Windows 10/11

## Feature overview

| Feature | GNOME | KDE 6 | Windows |
|---|---|---|---|
| Eight images | Yes | Yes | Yes |
| Time-based switching | Yes | Yes, through a script | Yes, through a script |
| Smooth transitions | Yes | No | No |
| Desktop and lock screen | Separate settings | Yes, through a script | Yes, through a script |
| GNOME XML | Native | Read by the script | Read by the script |
| Additional wallpaper plugin | No | No | No |

## GNOME

GNOME supports timed XML slideshows natively.

Install with:

```bash
bash ./install-gnome.sh
```

The installer configures:

- `org.gnome.desktop.background picture-uri`
- `org.gnome.desktop.background picture-uri-dark`

Both keys point to the XML slideshow.

The images and source XML are not copied anywhere. Only a runtime GNOME XML file with absolute paths into this package is created in `config/`.

Note: This installer does not automatically configure the GNOME lock-screen background.

Detailed guide: `docs/INSTALLATION-GNOME.md`.

## KDE Plasma 6

KDE supports time-based switching through a systemd user timer and the Plasma D-Bus API.

Use the current `install-kde.sh`:

```bash
bash ./install-kde.sh
```

The script:

- Creates a systemd user timer.
- Derives eight daily changes from the XML.
- Synchronizes the desktop and KDE lock screen.
- Restores the correct state on login.

The images, XML, and helper updater are not copied anywhere.

The KDE lock screen is not the same as the SDDM login screen.

Detailed guide: `docs/INSTALLATION-KDE.md`.

## Windows 10/11

Install with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1
```

The installer:

- Reads the XML.
- Registers scheduled wallpaper changes.
- Synchronizes the desktop and lock screen where the Windows API permits it.
- Restores the correct image on login.

The scheduled task points directly to the script in the extracted package. Files are not copied to `%LOCALAPPDATA%`.

Detailed guide: `docs/INSTALLATION-WINDOWS.md`.

## Daily phases

| Approximate time | Image |
|---|---|
| 05:22 | 01.png |
| 06:52 | 02.png |
| 08:30 | 03.png |
| 11:00 | 04.png |
| 14:00 | 05.png |
| 16:30 | 06.png |
| 18:30 | 07.png |
| 20:15 | 08.png |

GNOME uses smooth transitions, while KDE and Windows switch instantly.

KDE and Windows derive the switching times from the transition midpoints in the XML.

## Resolution and quality

- Eight PNG images.
- 3840 × 2160 resolution.
- Reconstructed 4K rather than natively generated 4K.
- Modernized light streams.
- Subtle movement of the planet, light points, and clouds.

See `docs/IMAGE-QUALITY.md` for details. Future regeneration instructions are maintained separately in `docs/PROMPT-INSTRUCTIONS.md`.
