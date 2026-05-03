#requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$IsoPath,
    [string]$VmName = 'DuckioOS-VM',
    [int]$MemoryGB = 4,
    [int]$DiskGB = 64,
    [string]$SwitchName = 'Default Switch'
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command New-VM -ErrorAction SilentlyContinue)) {
    throw 'Hyper-V PowerShell module is not available. Enable Hyper-V first.'
}
if (-not (Test-Path $IsoPath)) {
    throw "ISO not found: $IsoPath"
}

$vmRoot = "C:\ProgramData\Duckio\VM"
$vhdPath = Join-Path $vmRoot "$VmName.vhdx"
New-Item -ItemType Directory -Path $vmRoot -Force | Out-Null

if (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
    Write-Host "[Duckio] Removing existing VM $VmName"
    Stop-VM -Name $VmName -Force -TurnOff -ErrorAction SilentlyContinue
    Remove-VM -Name $VmName -Force
}

if (Test-Path $vhdPath) {
    Remove-Item $vhdPath -Force
}

New-VHD -Path $vhdPath -SizeBytes (${DiskGB}GB) -Dynamic | Out-Null
New-VM -Name $VmName -Generation 2 -MemoryStartupBytes (${MemoryGB}GB) -VHDPath $vhdPath -SwitchName $SwitchName | Out-Null
Set-VMFirmware -VMName $VmName -EnableSecureBoot On -SecureBootTemplate MicrosoftWindows
Add-VMDvdDrive -VMName $VmName -Path $IsoPath | Out-Null
Set-VMProcessor -VMName $VmName -Count 2

Start-VM -Name $VmName | Out-Null
Write-Host "[Duckio] VM started: $VmName" -ForegroundColor Green
