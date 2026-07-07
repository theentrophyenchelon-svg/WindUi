# WindUI GodTier Plus Upgrade

This package has been upgraded into a premium Roblox Luau UI library stack with a base WindUI build plus an additive GodTier Plus extension layer.

## Version

```text
1.8.0-godtier-plus
```

## What GodTier Plus adds

- Premium showcase builder: `WindUI:CreateGodTierShowcase()`.
- Safer premium window creation: `WindUI:CreateGodTierWindow(config)`.
- Motion profiles: Cinematic, Balanced, Snappy, and Reduced.
- Loading overlay system with animated card, progress bar, glow stroke, and auto-destroy behavior.
- Performance overlay with FPS and memory display.
- Theme Studio helpers for Aurora, Obsidian, Cyber, Royal, Dark, and Light.
- Premium notification helpers: `NotifyInfo`, `NotifySuccess`, `NotifyWarning`, and `NotifyError`.
- Reusable builders for Elements, Themes, Settings, and About tabs.
- Better package metadata for a polished public release.

## Recommended loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/main_example.lua"))()
```

## Manual GodTier Plus install

```lua
local repo = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(repo .. "dist/main.lua"))()
local InstallGodTierPlus = loadstring(game:HttpGet(repo .. "dist/godtier_plus.lua"))()

local GodTierPlus = InstallGodTierPlus(WindUI)
GodTierPlus:BuildShowcase()
```

## New public APIs

```lua
WindUI:NotifyInfo(title, content, duration)
WindUI:NotifySuccess(title, content, duration)
WindUI:NotifyWarning(title, content, duration)
WindUI:NotifyError(title, content, duration)

WindUI:SetGodTierMotionProfile("Balanced")
WindUI:CreateGodTierWindow(config)
WindUI:CreateGodTierLoadingOverlay(config)
WindUI:CreateGodTierPerformanceOverlay(config)
WindUI:CreateGodTierShowcase()
```

## Compatibility

GodTier Plus is additive. It does not replace the base `dist/main.lua` build, and old WindUI configs should continue to work. The extension uses safe `pcall` wrappers around optional APIs so unsupported features fail softly instead of crashing the whole UI.
