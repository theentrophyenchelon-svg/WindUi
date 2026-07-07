# Sentry Hub Library Upgrade

Sentry Hub Library is the polished public-facing identity for this Roblox Luau UI framework. The internal runtime still uses the WindUI object for compatibility, but the visible library branding, showcase UI, loading overlay, notifications, package metadata, and documentation now present as Sentry Hub Library.

## Version

```text
1.8.0-sentry
```

## What Sentry adds

- Premium showcase builder: `WindUI:CreateSentryShowcase()`.
- Safer premium window creation: `WindUI:CreateSentryWindow(config)`.
- Motion profiles: Cinematic, Balanced, Snappy, and Reduced.
- Loading overlay system with animated card, progress bar, glow stroke, and auto-destroy behavior.
- Performance overlay with FPS and memory display.
- Theme Studio helpers for Aurora, Obsidian, Cyber, Royal, Dark, and Light.
- Premium notification helpers: `NotifyInfo`, `NotifySuccess`, `NotifyWarning`, and `NotifyError`.
- Reusable builders for Elements, Themes, Settings, and About tabs.
- Delicate premium branding focused on clean, controlled, protective UI design.

## Recommended loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/main_example.lua"))()
```

## Manual Sentry install

```lua
local repo = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(repo .. "dist/main.lua"))()
local InstallSentryHub = loadstring(game:HttpGet(repo .. "dist/godtier_plus.lua"))()

local SentryHub = InstallSentryHub(WindUI)
SentryHub:BuildShowcase()
```

## New public APIs

```lua
WindUI:NotifyInfo(title, content, duration)
WindUI:NotifySuccess(title, content, duration)
WindUI:NotifyWarning(title, content, duration)
WindUI:NotifyError(title, content, duration)

WindUI:SetSentryMotionProfile("Balanced")
WindUI:CreateSentryWindow(config)
WindUI:CreateSentryLoadingOverlay(config)
WindUI:CreateSentryPerformanceOverlay(config)
WindUI:CreateSentryShowcase()
```

## Compatibility

The Sentry extension is additive. It does not replace the base `dist/main.lua` build, and old WindUI configs should continue to work. Previous GodTier Plus API names remain as aliases so older scripts do not instantly break.
