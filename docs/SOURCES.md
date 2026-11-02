<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# Official references and native-support boundaries

## Historical AllDayLong materials

- Local reference images: `original-AllDayLong/01.jpg` through `08.jpg`.
- Original timed configuration: `original-AllDayLong/AllDayLong.xml`.
- Content description and license notice: `original-AllDayLong/README.md`.

The historical images are not AI-generated. Their author and license have not been independently verified. Their presence in this repository does not by itself establish permission for further redistribution or the creation of derivative works.

This notice applies to the historical reference files. The separate license status of the new output PNG files is described in `../LICENSE.md`.

### Historical online references

| Date | Source | Details |
|---|---|---|
| 2008 | [GNOME-Look.org — original listing, ID 83443](https://www.gnome-look.org/content/show.php?content=83443) | Historical link to the original publication; the page may no longer be available. |
| July 23, 2008 | [Ubuntu Life — Animated wallpaper that changes by time of day](https://ubuntulife.wordpress.com/2008/07/23/wallpaper-animado-que-cambia-segun-la-hora-del-dia/) | Contemporary article containing a GNOME XML configuration that references all eight images. |
| August 2008 | [Ars Technica — Post your *nix desktop](https://arstechnica.com/civis/threads/post-your-nix-desktop.33865/) | Discussion mentioning eight day/night variants and GNOME-Look. |
| September 18, 2010 | [TiTrixs — AllDayLong Linux installation](https://titrixs.blogspot.com/2010/09/) | Indonesian installation and usage guide. |

## GNOME

- [GSettings (`gsettings`) as the supported user configuration interface](https://help.gnome.org/system-admin-guide/gsettings-browse.html)
- [Desktop-background configuration through dconf](https://help.gnome.org/system-admin-guide/desktop-background.html)
- [GNOME Settings → Appearance](https://help.gnome.org/gnome-help/look-background.html)
- [Slideshow XML technical guide in the Ubuntu community documentation](https://help.ubuntu.com/community/SlideshowWallpapers)

## KDE Plasma

- [Configure the wallpaper through the desktop](https://docs.kde.org/stable_kf6/en/plasma-desktop/plasma-desktop/desktop.html)
- [KDE wallpaper plugins](https://develop.kde.org/docs/plasma/)
- [KDE Plasma Scripting API](https://develop.kde.org/docs/plasma/scripting/api/)

## Windows

- [Microsoft Support: change the desktop background](https://support.microsoft.com/windows/change-the-desktop-background-in-windows)
- [Microsoft Task Scheduler](https://learn.microsoft.com/windows/win32/taskschd/about-the-task-scheduler)
- [`IDesktopWallpaper::SetWallpaper`](https://learn.microsoft.com/windows/win32/api/shobjidl_core/nf-shobjidl_core-idesktopwallpaper-setwallpaper)
- [`.theme` file format](https://learn.microsoft.com/windows/win32/controls/themesfileformat-overview)

Note: `AllDayLong-2026.xml` is a **timed slideshow definition**, which differs from the `gnome-background-properties` XML wallpaper list. GNOME uses it natively. The KDE and Windows installation scripts derive discrete changes from the midpoint of each XML transition; those environments do not read GNOME XML natively.
