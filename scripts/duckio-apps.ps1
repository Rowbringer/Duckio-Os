#requires -RunAsAdministrator
[CmdletBinding()]
param()

$apps = @(
    '7zip.7zip',
    'Git.Git',
    'Microsoft.PowerShell',
    'Microsoft.VisualStudioCode',
    'Brave.Brave',
    'VideoLAN.VLC'
)

foreach ($id in $apps) {
    Write-Host "[Duckio] Installing $id"
    winget install --id $id --silent --accept-source-agreements --accept-package-agreements
}
