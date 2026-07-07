<div align="center">

<img src="docs/banner-new.webp" alt="Sentry Hub Library Banner" width="100%" />

# Sentry Hub Library

### A delicate premium Roblox Luau UI framework for cinematic hubs, polished menus, and refined in-game interfaces.

Sentry Hub Library is built for developers who want their Roblox UI to feel controlled, elegant, smooth, and production-ready. It combines a modern component system with premium motion, theme presets, acrylic visuals, loading overlays, performance feedback, notification helpers, and a clean developer workflow.

<br />

[![Roblox](https://img.shields.io/badge/Platform-Roblox-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![Luau](https://img.shields.io/badge/Language-Luau-2C74B3?style=for-the-badge)](https://luau.org/)
[![Version](https://img.shields.io/badge/Version-1.8.0--sentry-30FF6A?style=for-the-badge)](#version)
[![Status](https://img.shields.io/badge/Status-Premium%20Framework-8A2BE2?style=for-the-badge)](#about-sentry-hub-library)
[![License](https://img.shields.io/github/license/theentrophyenchelon-svg/WindUi?style=for-the-badge)](LICENSE)

[![Stars](https://img.shields.io/github/stars/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/stargazers)
[![Forks](https://img.shields.io/github/forks/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/forks)
[![Watchers](https://img.shields.io/github/watchers/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/watchers)

</div>

---

## About Sentry Hub Library

Sentry Hub Library is a refined Roblox UI framework designed for clean, deliberate, high-quality interface design. It is made for developers building script hubs, admin panels, dashboards, game menus, settings panels, ability menus, and premium in-game tools that need to feel smooth instead of rushed.

The public-facing brand is **Sentry Hub Library**. The internal runtime still exposes the `WindUI` object for compatibility, so existing scripts keep working while the visible UI, documentation, package metadata, showcase loader, loading overlay, and premium extension layer present under the Sentry identity.

### Why it feels premium

- **Delicate visual style** — clean radius, soft contrast, acrylic surfaces, refined strokes, and balanced spacing.
- **Controlled motion** — cinematic, balanced, snappy, and reduced-motion profiles.
- **Powerful theme studio** — Aurora, Obsidian, Cyber, Royal, Dark, and Light presets.
- **Complete element suite** — windows, tabs, sections, buttons, toggles, sliders, dropdowns, inputs, keybinds, colorpickers, notifications, and more.
- **Performance tools** — optional FPS and memory overlay for quick UI performance checks.
- **Premium overlays** — animated loading overlay with progress feedback and soft presentation.
- **Developer-friendly API** — additive Sentry helpers layered on top of the compatible base runtime.

---

## Live Repository Stats

> Badge services may not show live values while the repository is private. They update normally when the repository is public.

| Metric | Badge |
|---|---|
| Last Commit | ![Last Commit](https://img.shields.io/github/last-commit/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Repository Size | ![Repo Size](https://img.shields.io/github/repo-size/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Code Size | ![Code Size](https://img.shields.io/github/languages/code-size/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Top Language | ![Top Language](https://img.shields.io/github/languages/top/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Languages | ![Languages](https://img.shields.io/github/languages/count/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Open Issues | ![Issues](https://img.shields.io/github/issues/theentrophyenchelon-svg/WindUi?style=flat-square) |

---

## Quick Start

Use the complete showcase loader:

```luau
loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/main_example.lua"))()
```

Manual install:

```luau
local repo = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(repo .. "dist/main.lua"))()
local InstallSentryHub = loadstring(game:HttpGet(repo .. "dist/godtier_plus.lua"))()

local SentryHub = InstallSentryHub(WindUI)
SentryHub:BuildShowcase()
```

---

## Minimal Sentry Window

```luau
local repo = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(repo .. "dist/main.lua"))()
local InstallSentryHub = loadstring(game:HttpGet(repo .. "dist/godtier_plus.lua"))()
InstallSentryHub(WindUI)

local window = WindUI:CreateSentryWindow({
	Title = "Sentry Hub Library",
	Icon = "shield-check",
	Author = "Premium Roblox UI Framework",
	Theme = "Aurora",
})

local main = window:Tab({
	Title = "Main",
	Icon = "home",
	Border = true,
})

main:Button({
	Title = "Launch",
	Desc = "Runs a polished Sentry interaction.",
	Callback = function()
		WindUI:NotifySuccess("Sentry Hub Library", "Interaction launched.")
	end,
})
```

---

## Feature Matrix

| System | Included |
|---|---|
| Window System | Premium shell, tabs, sections, topbar buttons, open button, acrylic, glow, radius controls |
| Elements | Button, Toggle, Slider, Dropdown, Input, Keybind, Colorpicker, Paragraph, Divider, Image, Video, Viewport |
| Sentry Extension | Showcase builder, safer window defaults, motion profiles, loading overlay, performance overlay |
| Feedback | Notifications, popups, dialogs, hover states, press states, ripple-style interactions |
| Themes | Aurora, Obsidian, Cyber, Royal, Dark, Light, and custom theme support |
| Performance | FPS and memory overlay, reduced-motion mode, UI scale control |
| Build | `dist/main.lua`, `dist/godtier_plus.lua`, build tooling, package metadata, Rojo project config |
| Examples | Hosted showcase loader, Studio/local examples, advanced demo window |

---

## Sentry APIs

| API | Purpose |
|---|---|
| `WindUI:CreateSentryShowcase()` | Builds the full Sentry showcase UI. |
| `WindUI:CreateSentryWindow(config)` | Creates a Sentry-branded premium window. |
| `WindUI:SetSentryMotionProfile(profile)` | Applies Cinematic, Balanced, Snappy, or Reduced motion. |
| `WindUI:CreateSentryLoadingOverlay(config)` | Shows the animated loading card overlay. |
| `WindUI:CreateSentryPerformanceOverlay(config)` | Shows FPS and memory stats. |
| `WindUI:NotifyInfo(title, content, duration)` | Sends an info notification. |
| `WindUI:NotifySuccess(title, content, duration)` | Sends a success notification. |
| `WindUI:NotifyWarning(title, content, duration)` | Sends a warning notification. |
| `WindUI:NotifyError(title, content, duration)` | Sends an error notification. |

Previous GodTier Plus names remain as aliases for compatibility.

---

## Project Structure

```text
Sentry Hub Library/
├── .github/workflows/       # Build, pull request, and release automation
├── build/                   # DarkLua and packaging scripts
├── dist/                    # Public runtime output
│   ├── main.lua             # Base UI runtime
│   └── godtier_plus.lua     # Sentry premium extension layer
├── docs/                    # Visual assets, banners, previews, and branding
├── src/                     # Main Luau source
├── tests/                   # Stress and rendering examples
├── main.lua                 # Studio/local example
├── main.client.lua          # Advanced client demo
├── main_example.lua         # Hosted Sentry showcase loader
├── package.json             # Project metadata and scripts
└── GODTIER_UPGRADE.md       # Upgrade/API notes
```

---

## Development

```bash
npm install
npm run build
npm run dev
```

---

## Version

```text
1.8.0-sentry
```

---

## Credits

Sentry Hub Library is built on a compatible WindUI runtime foundation and includes or references high-quality icon systems:

- [Lucide Icons](https://github.com/lucide-icons/lucide)
- [Craft Icons](https://www.figma.com/community/file/1415718327120418204)
- [Geist Icons](https://vercel.com/geist/icons)
- [Solar Icons](https://icones.js.org/collection/solar)
- [SF Symbols](https://sf-symbols-one.vercel.app/)

---

<div align="center">

## Sentry Hub Library

### Delicate design. Premium motion. Protective interface energy.

Built for Roblox interfaces that deserve to feel finished.

</div>
