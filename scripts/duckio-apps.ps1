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
    'VideoLAN.VLC',
    'Microsoft.MinecraftLauncher',
    'Roblox.Roblox'
)

$installList = if ($Apps -and $Apps.Count -gt 0) { $Apps } else { $defaultApps }

foreach ($id in $installList) {
    Write-Host "[Duckio] Installing $id"
    winget install --id $id --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "[Duckio] Install failed for $id (exit code: $LASTEXITCODE)"
    }
}
