<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# AllDayLong 2026 – KDE Plasma 6

Automatically changes the desktop and lock-screen wallpaper according to the time of day.

## Features

- Eight daily states.
- Precise time-based switching through a systemd user timer.
- Desktop and KDE lock-screen synchronization.
- KDE Plasma 6 support on both X11 and Wayland.
- Restoration of the correct wallpaper on login.
- No external wallpaper plugin.

## Requirements

- KDE Plasma 6.
- Linux with systemd user services.
- Python 3.
- `kwriteconfig6`.
- `qdbus6` or `gdbus`.
- `install-kde.sh`.
- Images `01.png` through `08.png`.
- `config/AllDayLong-2026.xml`.

## Installation

Place `install-kde.sh` in the extracted AllDayLong directory next to the `images/` directory.

Run it without `sudo`:

```bash
bash ./install-kde.sh
```

The installer creates:

    ~/.config/systemd/user/alldaylong-kde.service
    ~/.config/systemd/user/alldaylong-kde.timer
    ~/.config/autostart/alldaylong-kde.desktop

It then enables the systemd user timer. The unit and autostart entry point directly to `install-kde.sh` in this package; the images, XML, and helper updater are not copied.

Keep the extracted directory in a private user-owned location that other users cannot modify. Systemd and the autostart entry continue to run the installation script from this directory. Do not move or delete it; if you move it, rerun the installer from the new location.

## Daily schedule

| Time | Image | Phase |
|---|---|---|
| 05:22 | 01.png | Dawn |
| 06:52 | 02.png | Morning |
| 08:30 | 03.png | Late morning |
| 11:00 | 04.png | Midday |
| 14:00 | 05.png | Afternoon |
| 16:30 | 06.png | Golden hour |
| 18:30 | 07.png | Dusk |
| 20:15 | 08.png | Night |

The installer derives these times from the transition midpoints in `config/AllDayLong-2026.xml`. The first two changes therefore occur at exactly `05:22:30` and `06:52:30`; the table rounds them to the nearest minute.

After changing the XML, rerun the installer to regenerate the systemd timer. Manual synchronization and the scheduled service always determine the current image directly from the XML.

## Lock-screen synchronization

The installer updates:

    ~/.config/kscreenlockerrc

It uses the following configuration path:

    Greeter
    Wallpaper / org.kde.image / General / Image

The desktop is updated through the Plasma Scripting API and D-Bus.

The lock screen normally loads the new background the next time the session is locked.

**Note:** This is the KDE user lock screen, not the SDDM login screen.

## Verification

Check the timer status:

```bash
systemctl --user status alldaylong-kde.timer
systemctl --user list-timers --all alldaylong-kde.timer
```

Synchronize manually:

```bash
bash ./install-kde.sh --apply
```

View the log:

```bash
journalctl --user -u alldaylong-kde.service -n 30 --no-pager
```

Verify the lock-screen setting:

```bash
kreadconfig6 --file kscreenlockerrc \
  --group Greeter \
  --group Wallpaper \
  --group org.kde.image \
  --group General \
  --key Image
```

After manual synchronization, lock the session with `Meta+L` and check the displayed image.

## Multiple monitors

The script sets the wallpaper on every available Plasma desktop containment.

When using multiple activities or a custom monitor layout, verify the resulting configuration on every display.

## Limitations

- Switching is instantaneous and does not use GNOME XML transitions.
- Schedule changes require rerunning the installer to update the timer.
- The lock screen may not refresh its background while it is already active.
- SDDM is not modified.
- Switching may be delayed while the system is suspended.
- This functionality has not been verified on an actual KDE Plasma installation.

## Uninstallation

```bash
bash install-kde.sh --uninstall
```

This removes the timer, service, autostart entry, and launcher script.

The package remains unchanged in its original location. The previous desktop and lock-screen configuration is not restored automatically.

## Official documentation

- [KDE Plasma Scripting API](https://develop.kde.org/docs/plasma/scripting/)
- [systemd.timer](https://www.freedesktop.org/software/systemd/man/latest/systemd.timer.html)
- [KDE Plasma documentation](https://docs.kde.org/)
