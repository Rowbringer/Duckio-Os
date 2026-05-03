#requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string[]]$Apps
)

$defaultApps = @(
    '7zip.7zip',
    'Git.Git',
    'Microsoft.PowerShell',
    'Microsoft.VisualStudioCode',
    'Brave.Brave',
    'VideoLAN.VLC'
)

$installList = if ($Apps -and $Apps.Count -gt 0) { $Apps } else { $defaultApps }

foreach ($id in $installList) {
    Write-Host "[Duckio] Installing $id"
    winget install --id $id --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
}
