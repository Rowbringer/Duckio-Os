# Duckio Gaming Pack

Duckio OS now includes optional gaming defaults through Winget package IDs:

- `Microsoft.MinecraftLauncher`
- `Roblox.Roblox`

These are installed by default when running:

```powershell
C:\duckio\duckio-setup.ps1
```

If you want a custom set of apps:

```powershell
C:\duckio\duckio-apps.ps1 -Apps @('Microsoft.MinecraftLauncher','Roblox.Roblox')
```

## Verify install

```powershell
winget list Microsoft.MinecraftLauncher
winget list Roblox.Roblox
```
