#requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$SkipApps,
    [switch]$Rollback,
    [switch]$StrictPrivacy
)

$ErrorActionPreference = 'Stop'
$logDir = 'C:\ProgramData\Duckio'
$logFile = Join-Path $logDir 'duckio-setup.log'
$backupFile = Join-Path $logDir 'registry-backup.json'

if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

Start-Transcript -Path $logFile -Append | Out-Null

$settings = @(
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Type='DWord'; Value=1; Rollback=3 },
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableWindowsConsumerFeatures'; Type='DWord'; Value=1; Rollback=0 },
    @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name='Enabled'; Type='DWord'; Value=0; Rollback=1 },
    @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'; Name='GlobalUserDisabled'; Type='DWord'; Value=1; Rollback=0 },
    @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarDa'; Type='DWord'; Value=0; Rollback=1 },
    @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name='TaskbarMn'; Type='DWord'; Value=0; Rollback=1 }
)

if ($StrictPrivacy) {
    $settings += @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Type='DWord'; Value=0; Rollback=3 }
}

function Set-RegValue {
    param(
        [Parameter(Mandatory)] [hashtable]$Item
    )

    if (-not (Test-Path $Item.Path)) {
        New-Item -Path $Item.Path -Force | Out-Null
    }

    New-ItemProperty -Path $Item.Path -Name $Item.Name -Value $Item.Value -PropertyType $Item.Type -Force | Out-Null
}

function Get-RegValueOrNull {
    param([hashtable]$Item)
    try {
        return (Get-ItemProperty -Path $Item.Path -Name $Item.Name -ErrorAction Stop).$($Item.Name)
    } catch {
        return $null
    }
}

function Save-Backup {
    $snapshot = foreach ($item in $settings) {
        [PSCustomObject]@{
            Path = $item.Path
            Name = $item.Name
            Type = $item.Type
            PreviousValue = Get-RegValueOrNull -Item $item
            RollbackValue = $item.Rollback
        }
    }
    $snapshot | ConvertTo-Json -Depth 5 | Out-File -FilePath $backupFile -Encoding utf8
}

function Restore-Backup {
    if (-not (Test-Path $backupFile)) {
        throw "No backup file found at $backupFile"
    }
    $restoreData = Get-Content -Raw -Path $backupFile | ConvertFrom-Json
    foreach ($item in $restoreData) {
        if (-not (Test-Path $item.Path)) { New-Item -Path $item.Path -Force | Out-Null }
        $value = if ($null -ne $item.PreviousValue) { $item.PreviousValue } else { $item.RollbackValue }
        New-ItemProperty -Path $item.Path -Name $item.Name -Value $value -PropertyType DWord -Force | Out-Null
    }
}

try {
    if ($Rollback) {
        Write-Host '[Duckio] Rolling back registry settings from backup...'
        Restore-Backup
        Write-Host '[Duckio] Rollback complete. Reboot recommended.' -ForegroundColor Yellow
        return
    }

    Write-Host '[Duckio] Creating restore point...'
    Enable-ComputerRestore -Drive 'C:\' | Out-Null
    Checkpoint-Computer -Description 'Duckio Setup Restore Point' -RestorePointType MODIFY_SETTINGS | Out-Null

    Write-Host '[Duckio] Saving registry backup...'
    Save-Backup

    Write-Host '[Duckio] Applying registry settings...'
    foreach ($item in $settings) {
        Set-RegValue -Item $item
    }

    Write-Host '[Duckio] Disabling CEIP tasks...'
    Get-ScheduledTask -TaskPath '\Microsoft\Windows\Customer Experience Improvement Program\' -ErrorAction SilentlyContinue |
      Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null

    Write-Host '[Duckio] Applying power defaults...'
    powercfg /SETACTIVE SCHEME_BALANCED | Out-Null
    powercfg /CHANGE monitor-timeout-ac 15 | Out-Null
    powercfg /CHANGE disk-timeout-ac 0 | Out-Null

    if (-not $SkipApps) {
        & "$PSScriptRoot\duckio-apps.ps1"
    }

    Write-Host '[Duckio] Completed successfully. Reboot recommended.' -ForegroundColor Green
}
finally {
    Stop-Transcript | Out-Null
}
