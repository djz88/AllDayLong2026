# SPDX-FileCopyrightText: 2026 AllDayLong 2026 project contributors
# SPDX-License-Identifier: GPL-3.0-or-later
# AllDayLong 2026 - Windows 10/11
# Unified installer and wallpaper updater
# Windows PowerShell 5.1 (64-bit)
#
# Install:   .\install-windows.ps1
# Update:    .\install-windows.ps1
# Apply:     .\install-windows.ps1 -Apply
# Uninstall: .\install-windows.ps1 -Uninstall

param(
    [switch]$Apply,
    [switch]$Uninstall,
    [switch]$DesktopOnly,
    [switch]$LockScreenOnly,
    [switch]$Log
)

$ErrorActionPreference = 'Stop'

$taskName = 'AllDayLong2026'
$scriptPath = (Resolve-Path -LiteralPath $PSCommandPath).ProviderPath
$sourceRoot = Split-Path -Parent $scriptPath
$xmlPath = Join-Path $sourceRoot 'config\AllDayLong-2026.xml'
$imagePath = Join-Path $sourceRoot 'images'
$logPath = Join-Path $sourceRoot 'last-status.log'

if ($DesktopOnly -and $LockScreenOnly) {
    throw 'Choose only one mode.'
}

if ($Apply -and $Uninstall) {
    throw 'Apply and Uninstall cannot be combined.'
}

# -----------------------------------------------------
# APPLY WALLPAPER
# -----------------------------------------------------

function Set-AllDayLongWallpaper {

    param(
        [switch]$DesktopOnly,
        [switch]$LockScreenOnly,
        [switch]$Log
    )

    if (-not (Test-Path -LiteralPath $xmlPath)) {
        throw "Missing XML: $xmlPath"
    }

    [xml]$config = Get-Content `
        -LiteralPath $xmlPath `
        -Raw -Encoding UTF8

    $start = $config.background.starttime

    $startSeconds = [int]$start.hour * 3600 +
                    [int]$start.minute * 60 +
                    [int]$start.second

    $elapsed = (
        (Get-Date).TimeOfDay.TotalSeconds -
        $startSeconds + 86400
    ) % 86400

    $cursor = 0.0
    $filename = $null

    foreach ($item in $config.background.ChildNodes) {

        if ($item.Name -notin @('static', 'transition')) {
            continue
        }

        $duration = [double]::Parse(
            $item.SelectSingleNode('duration').InnerText,
            [Globalization.CultureInfo]::InvariantCulture
        )

        if (
            $elapsed -ge $cursor -and
            $elapsed -lt ($cursor + $duration)
        ) {

            if ($item.Name -eq 'static') {

                $filename = [IO.Path]::GetFileName(
                    $item.SelectSingleNode('file').InnerText
                )

            }
            elseif ($elapsed -lt ($cursor + $duration / 2)) {

                $filename = [IO.Path]::GetFileName(
                    $item.SelectSingleNode('from').InnerText
                )

            }
            else {

                $filename = [IO.Path]::GetFileName(
                    $item.SelectSingleNode('to').InnerText
                )
            }

            break
        }

        $cursor += $duration
    }

    if (-not $filename) {
        throw "No wallpaper found for current time."
    }

    if ($filename -notmatch '^0[1-8]\.png$') {
        throw "Unexpected image: $filename"
    }

    $wallpaper = Join-Path $imagePath $filename

    if (-not (Test-Path -LiteralPath $wallpaper)) {
        throw "Missing image: $wallpaper"
    }

    $wallpaper = (
        Resolve-Path -LiteralPath $wallpaper
    ).ProviderPath

    $desktopOK = $false
    $lockOK = $false
    $lockError = $null

    # -------------------------------------------------
    # DESKTOP
    # -------------------------------------------------

    if (-not $LockScreenOnly) {

        if (-not ('AllDayLongWallpaper' -as [type])) {

            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class AllDayLongWallpaper
{
    [DllImport(
        "user32.dll",
        EntryPoint = "SystemParametersInfoW",
        CharSet = CharSet.Unicode,
        SetLastError = true)]
    public static extern bool Apply(
        int action,
        int param,
        string path,
        int flags
    );
}
'@
        }

        $success = [AllDayLongWallpaper]::Apply(
            0x0014,
            0,
            $wallpaper,
            0x0003
        )

        if (-not $success) {
            $winerr = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            throw "Desktop wallpaper failed: Win32 error $winerr"
        }

        $desktopOK = $true
    }

    # -------------------------------------------------
    # LOCK SCREEN
    # -------------------------------------------------

    if (-not $DesktopOnly) {

        try {

            if (-not [Environment]::Is64BitProcess) {
                throw '64-bit PowerShell required.'
            }

            # Windows Runtime types
            [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
            [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
            Add-Type -AssemblyName System.Runtime.WindowsRuntime

            $methods = [System.WindowsRuntimeSystemExtensions].GetMethods()

            # IAsyncOperation<T> -> Task<T>
            $asTaskGeneric = @(
                $methods | Where-Object {
                    $_.Name -eq 'AsTask' -and
                    $_.IsGenericMethodDefinition -and
                    $_.GetParameters().Count -eq 1 -and
                    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
                }
            ) | Select-Object -First 1

            # IAsyncAction -> Task
            $asTaskAction = @(
                $methods | Where-Object {
                    $_.Name -eq 'AsTask' -and
                    -not $_.IsGenericMethod -and
                    $_.GetParameters().Count -eq 1 -and
                    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction'
                }
            ) | Select-Object -First 1

            if (-not $asTaskGeneric -or -not $asTaskAction) {
                throw 'WinRT async support unavailable.'
            }

            # Load PNG
            $storageOp = [Windows.Storage.StorageFile]::GetFileFromPathAsync(
                $wallpaper
            )

            $storageTask = $asTaskGeneric.MakeGenericMethod(
                [Windows.Storage.StorageFile]
            ).Invoke($null, @($storageOp))

            $storageFile = $storageTask.GetAwaiter().GetResult()

            # Set lock screen
            $setOp = [Windows.System.UserProfile.LockScreen]::SetImageFileAsync(
                $storageFile
            )

            $setTask = $asTaskAction.Invoke(
                $null, @($setOp)
            )

            [void]$setTask.GetAwaiter().GetResult()

            $lockOK = $true

        }
        catch {
            $lockError = $_.Exception.Message
            Write-Warning "Lock screen update failed: $lockError"
        }
    }

    # -------------------------------------------------
    # STATUS LOG
    # -------------------------------------------------

    # -----------------------------------------------------
# OPTIONAL STATUS LOG
# -----------------------------------------------------

    $now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $logLine = "$now image=$filename desktop=$desktopOK lock=$lockOK"

    if ($lockError) {
        $logLine += " lock-error=$lockError"
    }

    if ($Log) {
        try {
            Add-Content `
                -LiteralPath $logPath `
                -Encoding UTF8 `
                -Value $logLine
        }
        catch {
            Write-Warning 'Unable to write status log.'
        }
    }

    Write-Output $logLine

    if ($LockScreenOnly -and -not $lockOK) {
        exit 2
    }
}

# -----------------------------------------------------
# INSTALL / UPDATE
# -----------------------------------------------------

function Install-AllDayLong {

    param(
        [switch]$Log
    )

    if (-not [Environment]::Is64BitProcess) {
        throw '64-bit Windows PowerShell required.'
    }

    if (-not (Test-Path -LiteralPath $xmlPath)) {
        throw "Missing XML: $xmlPath"
    }

    foreach ($number in 1..8) {

        $name = '{0:D2}.png' -f $number

        $packageImage = Join-Path $imagePath $name

        if (-not (Test-Path -LiteralPath $packageImage)) {
            throw "Missing image: $packageImage"
        }
    }

    # -------------------------------------------------
    # READ SCHEDULE
    # -------------------------------------------------

    [xml]$config = Get-Content `
        -LiteralPath $xmlPath `
        -Raw -Encoding UTF8

    $time = $config.background.starttime

    $seconds = [int]$time.hour * 3600 +
               [int]$time.minute * 60 +
               [int]$time.second

    $durations = 0.0
    $triggers = @()

    $me = [Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Refresh on login
    $triggers += New-ScheduledTaskTrigger `
        -AtLogOn -User $me

    foreach ($item in $config.background.ChildNodes) {

        if ($item.Name -notin @('static', 'transition')) {
            continue
        }

        $duration = [double]::Parse(
            $item.SelectSingleNode('duration').InnerText,
            [Globalization.CultureInfo]::InvariantCulture
        )

        if ($duration -le 0) {
            throw 'Invalid duration in XML.'
        }

        if ($item.Name -eq 'transition') {

            # Switch halfway through XML transition
            $midpoint = ($seconds + $duration / 2) % 86400

            $at = (Get-Date).Date.AddSeconds($midpoint)

            $triggers += New-ScheduledTaskTrigger `
                -Daily -At $at
        }

        $seconds += $duration
        $durations += $duration
    }

    if ([Math]::Abs($durations - 86400.0) -gt 0.01) {
        throw "XML must describe exactly 24 hours."
    }

    # -------------------------------------------------
    # SCHEDULED TASK
    # -------------------------------------------------

    $arguments = '-NoProfile -NonInteractive ' +
                 '-WindowStyle Hidden ' +
                 '-ExecutionPolicy Bypass ' +
                 '-File "' + $scriptPath + '" -Apply'

    if ($Log) {
        $arguments += ' -Log'
    }

    $action = New-ScheduledTaskAction `
        -Execute (Join-Path $PSHOME 'powershell.exe') `
        -Argument $arguments

    $principal = New-ScheduledTaskPrincipal `
        -UserId $me `
        -LogonType Interactive `
        -RunLevel Limited

    $settings = New-ScheduledTaskSettingsSet `
        -StartWhenAvailable `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries

    # Update existing task instead of creating a second one
    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $triggers `
        -Principal $principal `
        -Settings $settings `
        -Description 'AllDayLong desktop and lock screen' `
        -Force | Out-Null

    # Apply immediately
    $applyArgs = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', $scriptPath,
        '-Apply'
    )

    if ($Log) {
        $applyArgs += '-Log'
    }

    & (Join-Path $PSHOME 'powershell.exe') @applyArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Initial wallpaper update exited with code $LASTEXITCODE."
    }

    Write-Output "AllDayLong uses package in place: $sourceRoot"
    Write-Output "Scheduled transitions: $($triggers.Count - 1)"
    if ($Log) {
        Write-Output "Log: $logPath"
    }
    Write-Output 'Do not move or delete this directory; rerun the installer after moving it.'
}

# -----------------------------------------------------
# UNINSTALL
# -----------------------------------------------------

function Uninstall-AllDayLong {

    $task = Get-ScheduledTask `
        -TaskName $taskName `
        -ErrorAction SilentlyContinue

    if ($task) {
        Unregister-ScheduledTask `
            -TaskName $taskName `
            -Confirm:$false
    }

    Write-Output 'AllDayLong scheduled task removed.'
    Write-Output "Package retained unchanged in $sourceRoot"
}

# -----------------------------------------------------
# ENTRY POINT
# -----------------------------------------------------

if ($Uninstall) {
    Uninstall-AllDayLong
}
elseif ($Apply) {
    Set-AllDayLongWallpaper `
        -DesktopOnly:$DesktopOnly `
        -LockScreenOnly:$LockScreenOnly `
        -Log:$Log
}
else {
    Install-AllDayLong -Log:$Log
}
