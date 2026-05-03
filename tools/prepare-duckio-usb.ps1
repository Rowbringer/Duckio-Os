#requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$IsoPath,
    [Parameter(Mandatory)] [string]$UsbDiskNumber,
    [Parameter(Mandatory)] [string]$UsbDriveLetter,
    [switch]$NoFormat,
    [switch]$LaunchVm
)

$ErrorActionPreference = 'Stop'

function Assert-File($path) {
    if (-not (Test-Path $path)) { throw "File not found: $path" }
}

Assert-File $IsoPath
Assert-File "$PSScriptRoot\..\scripts\duckio-setup.ps1"
Assert-File "$PSScriptRoot\..\scripts\duckio-apps.ps1"

if (-not $NoFormat) {
    $diskpartScript = @"
select disk $UsbDiskNumber
clean
convert gpt
create partition primary
format fs=fat32 quick label=DUCKIO_OS
assign letter=$UsbDriveLetter
exit
"@
    $tmp = Join-Path $env:TEMP "duckio-diskpart.txt"
    Set-Content -Path $tmp -Value $diskpartScript -Encoding ascii
    diskpart /s $tmp
}

$mount = Mount-DiskImage -ImagePath $IsoPath -PassThru
$vol = ($mount | Get-Volume | Select-Object -First 1)
$isoLetter = $vol.DriveLetter + ':'
$usbRoot = "$UsbDriveLetter`:"

Write-Host "[Duckio] Copying Windows setup files from $isoLetter to $usbRoot"
robocopy "$isoLetter\" "$usbRoot\" /E

$duckioRoot = Join-Path $usbRoot 'duckio'
New-Item -Path $duckioRoot -ItemType Directory -Force | Out-Null
Copy-Item "$PSScriptRoot\..\scripts\duckio-setup.ps1" "$duckioRoot\duckio-setup.ps1" -Force
Copy-Item "$PSScriptRoot\..\scripts\duckio-apps.ps1" "$duckioRoot\duckio-apps.ps1" -Force
Copy-Item "$PSScriptRoot\..\install\SetupComplete.cmd" "$duckioRoot\SetupComplete.cmd" -Force

Dismount-DiskImage -ImagePath $IsoPath

Write-Host '[Duckio] USB is ready.' -ForegroundColor Green
Write-Host "Install Windows from USB, then run: C:\duckio\duckio-setup.ps1 (as Administrator)."

if ($LaunchVm) {
    Write-Host '[Duckio] Launching VM installer preview with Hyper-V...'
    & "$PSScriptRoot\start-duckio-vm.ps1" -IsoPath $IsoPath
}
