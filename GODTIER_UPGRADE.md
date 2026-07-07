# Sentry Hub Library Contained Live Production Upgrade

Sentry Hub Library is now a contained production-grade Roblox Luau UI framework layered on top of the compatible WindUI runtime. The public runtime keeps `WindUI` for compatibility, while the production layer exposes Sentry-branded systems with sectioned tabs and live-updating contained panels.

## Version

```text
2.2.0-contained-live
```

## Contained production systems added

- Production showcase builder: `WindUI:CreateSentryShowcase()`.
- Production window defaults: `WindUI:CreateSentryWindow(config)`.
- Slower blocking intro that loads first, completes, disappears, then opens the UI smoothly.
- Sectioned tabs for Main, Elements, Visuals, Themes, Console Log, Friends, Key System, Settings, and About.
- Console Log tab with timestamped runtime logs inside the UI.
- Live performance monitor inside the Settings tab with FPS and memory updates.
- Player profile section inside Main using Roblox avatar thumbnail, username, display name, account id, and account age.
- Friend system tab with total friends, online count, offline count, and friends currently in the server.
- Image background preview using a text input for Roblox decal/image ids.
- Contained live background mode that updates UI state without spawning extra full-screen clutter.
- Animated theme cycle that changes themes live inside the library.
- Expanded theme studio with Aurora, Obsidian, Cyber, Royal, Velvet, Glacier, Solar, Eclipse, Crimson, Emerald, Dark, and Light compatibility.
- Highlight, glow, accent color, and stroke-focused feedback using supported library elements.
- Safer `pcall` wrapped builders so unsupported optional features fail softly instead of crashing the whole UI.

## Recommended production loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/main_example.lua"))()
```

## Manual production install

```lua
local repo = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(repo .. "dist/main.lua"))()
local InstallSentryProduction = loadstring(game:HttpGet(repo .. "dist/sentry_production.lua"))()

local Sentry = InstallSentryProduction(WindUI)
Sentry:BuildShowcase()
```

## Current contained public APIs

```lua
WindUI:CreateSentryShowcase()
WindUI:CreateSentryWindow(config)
WindUI:SetSentryMotionProfile("Balanced")
WindUI:GetSentryFriendSummary()

WindUI:NotifyInfo(title, content, duration)
WindUI:NotifySuccess(title, content, duration)
WindUI:NotifyWarning(title, content, duration)
WindUI:NotifyError(title, content, duration)
```

## Note on viewport/background limitations

The base public element API supports contained paragraphs, images, thumbnails, sections, tabs, buttons, inputs, dropdowns, toggles, keybinds, sliders, and colorpickers. Because it does not yet expose a raw custom mount slot, the current contained build uses Roblox avatar thumbnails inside the UI instead of spawning an external `ViewportFrame`, and image backgrounds are shown as contained UI previews instead of full-screen overlays.

## Note on security

The advanced key system is a polished client-side UX layer. For real access control, validate permissions and ownership from the server using RemoteEvents/RemoteFunctions and server-side checks.

## Compatibility

The production layer is additive. It does not replace `dist/main.lua`. The older `dist/godtier_plus.lua` extension remains available as a fallback, and the main showcase loader attempts `dist/sentry_production.lua` first before falling back.
