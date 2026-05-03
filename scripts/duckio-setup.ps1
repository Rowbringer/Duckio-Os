#requires -RunAsAdministrator
[CmdletBinding()]
param(
    [switch]$SkipApps
)

$ErrorActionPreference = 'Stop'
$logDir = 'C:\ProgramData\Duckio'
$logFile = Join-Path $logDir 'duckio-setup.log'

if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

Start-Transcript -Path $logFile -Append | Out-Null

function Set-RegDword {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [Parameter(Mandatory)] [string]$Name,
        [Parameter(Mandatory)] [int]$Value
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

try {
    Write-Host '[Duckio] Creating restore point...'
    Enable-ComputerRestore -Drive 'C:\' | Out-Null
    Checkpoint-Computer -Description 'Duckio Setup Restore Point' -RestorePointType MODIFY_SETTINGS | Out-Null

    Write-Host '[Duckio] Applying privacy + performance registry settings...'

    # Telemetry baseline (enterprise-safe)
    Set-RegDword -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 1

    # Consumer experiences off
    Set-RegDword -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Value 1

    # Advertising ID off
    Set-RegDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0

    # Background apps minimized (user scope)
    Set-RegDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Name 'GlobalUserDisabled' -Value 1

    # Hide taskbar widgets/chat clutter
    Set-RegDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0
    Set-RegDword -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarMn' -Value 0

    Write-Host '[Duckio] Disabling selected startup noise...'
    Get-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null

    Write-Host '[Duckio] Setting high quality power defaults (desktop/laptop safe)...'
    powercfg /SETACTIVE SCHEME_BALANCED | Out-Null
    powercfg /CHANGE monitor-timeout-ac 15 | Out-Null
    powercfg /CHANGE disk-timeout-ac 0 | Out-Null

    if (-not $SkipApps) {
        Write-Host '[Duckio] Installing optional apps via winget script...'
        & "$PSScriptRoot\duckio-apps.ps1"
    }

    Write-Host '[Duckio] Completed successfully. Reboot recommended.' -ForegroundColor Green
}
finally {
    Stop-Transcript | Out-Null
}
