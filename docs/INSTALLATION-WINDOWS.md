<!-- SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors -->
<!-- SPDX-License-Identifier: CC-BY-4.0 -->

# AllDayLong 2026 – Windows 10/11

Automatically changes the desktop and lock-screen wallpaper according to the time of day.

## Features

- Eight daily states.
- Precise time-based switching through Task Scheduler.
- A schedule derived from the GNOME XML.
- Desktop and lock-screen synchronization where permitted by the Windows API.
- Restoration of the correct wallpaper on login.
- No copying of images, XML, or the installation script.

## Requirements

- Windows 10 or Windows 11.
- 64-bit Windows PowerShell 5.1.
- Access to Task Scheduler.
- A user session that permits wallpaper changes.
- The extracted package in a permanent location.

## Package structure

```text
AllDayLong-2026-4K/
├── images/
│   ├── 01.png
│   └── ... 08.png
├── config/
│   └── AllDayLong-2026.xml
└── install-windows.ps1
```

## Installation

1. Extract the package to a permanent, private user-owned location such as `Pictures\AllDayLong-2026`. Other users must not have write access to it.
2. Open Windows PowerShell 5.1 as a regular user.
3. Change to the package root directory.
4. Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1
```

The installer:

- Verifies the XML and all eight images directly in the package.
- Derives the midpoint of every transition from the XML.
- Creates or updates the `AllDayLong2026` scheduled task.
- Applies the correct image immediately and again on every login.

The scheduled task points directly to `install-windows.ps1` in this directory. The images, XML, and script are not copied to `%LOCALAPPDATA%` or anywhere else.

Do not move or delete the directory after installation. If you move it, rerun the installer from the new location; it will update the existing task with the new path.

Installation normally does not require administrator privileges, but corporate policies may prevent scheduled-task registration.

## Daily schedule

The times are derived from the transition midpoints in `config/AllDayLong-2026.xml`.

| Approximate time | Image | Phase |
|---|---|---|
| 05:22:30 | 01.png | Dawn |
| 06:52:30 | 02.png | Morning |
| 08:30:00 | 03.png | Late morning |
| 11:00:00 | 04.png | Midday |
| 14:00:00 | 05.png | Afternoon |
| 16:30:00 | 06.png | Golden hour |
| 18:30:00 | 07.png | Dusk |
| 20:15:00 | 08.png | Night |

After changing the XML, rerun the installer to update the Task Scheduler triggers. Switching is instantaneous; Windows does not use the smooth transitions defined in the XML.

## Lock screen

`install-windows.ps1 -Apply` attempts to set the same PNG on both the desktop and lock screen.

It uses:

- `SystemParametersInfoW` for the desktop.
- `Windows.System.UserProfile.LockScreen.SetImageFileAsync()` for the lock screen.

In Settings → Personalization → Lock screen, select **Picture**. Windows Spotlight or a system slideshow may override the setting.

The lock-screen API may not work from every PowerShell session or under some security policies. A lock-screen failure does not undo a successful desktop update.

## Updating

Replace files directly in the permanent package directory and rerun:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1
```

The same scheduled task is updated; a second task is not created.

## Diagnostics

Check the task status:

```powershell
Get-ScheduledTask -TaskName AllDayLong2026
Get-ScheduledTaskInfo -TaskName AllDayLong2026
```

Synchronize manually:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Apply
```

Test only the lock screen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Apply -LockScreenOnly
```

Logging is optional. Enable it during installation with `-Log`; the same parameter is then stored in the scheduled task:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Log
Get-Content .\last-status.log -Tail 10
```

Log values mean:

- `desktop=True` — the desktop update succeeded.
- `lock=True` — the Windows API completed the lock-screen update.
- `lock=False` or `lock-error=...` — the lock-screen update failed.

## Uninstallation

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-windows.ps1 -Uninstall
```

This removes only the scheduled task. It does not remove package files or an optional `last-status.log`; restore the previous desktop and lock-screen images manually through Personalization.

## Known limitations

- Windows cannot reproduce GNOME XML smooth transitions.
- A scheduled change may be delayed while the device is sleeping or the session is inactive.
- The lock-screen API may not be available in every configuration.
- Corporate policies may override user settings.
- Changing the pre-login screen is outside the scope of the installer.
- The automation has not been verified on an actual Windows device.

## Official Microsoft documentation

- [Change the desktop background](https://support.microsoft.com/windows/change-the-desktop-background-in-windows)
- [Customize the lock screen](https://support.microsoft.com/windows/customize-the-lock-screen-in-windows)
- [Task Scheduler](https://learn.microsoft.com/windows/win32/taskschd/about-the-task-scheduler)
- [LockScreen API](https://learn.microsoft.com/uwp/api/windows.system.userprofile.lockscreen.setimagefileasync)
