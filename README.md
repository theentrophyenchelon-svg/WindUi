<div align="center">

# WindUI GodTier

### The premium, high-polish Roblox Luau UI library built for modern script hubs, admin panels, game tools, and next-level in-game interfaces.

WindUI GodTier is designed to feel fast, clean, cinematic, responsive, and production-ready. It combines a modern Roblox UI system with premium motion, theme presets, polished components, acrylic styling, ripple feedback, and a developer-friendly API.

<br />

[![Repository](https://img.shields.io/badge/GitHub-theentrophyenchelon--svg%2FWindUi-181717?style=for-the-badge&logo=github)](https://github.com/theentrophyenchelon-svg/WindUi)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-00A2FF?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com/)
[![Luau](https://img.shields.io/badge/Language-Luau-2C74B3?style=for-the-badge)](https://luau.org/)
[![Version](https://img.shields.io/badge/Version-1.7.0--godtier-8A2BE2?style=for-the-badge)](#version)
[![License](https://img.shields.io/github/license/theentrophyenchelon-svg/WindUi?style=for-the-badge)](LICENSE)

[![Stars](https://img.shields.io/github/stars/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/stargazers)
[![Forks](https://img.shields.io/github/forks/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/forks)
[![Watchers](https://img.shields.io/github/watchers/theentrophyenchelon-svg/WindUi?style=social)](https://github.com/theentrophyenchelon-svg/WindUi/watchers)

</div>

---

## Live Project Stats

> These badges update from GitHub automatically when the repository is public. If this repository stays private, some external badge services may not be able to read private metrics.

| Metric | Live Badge |
|---|---|
| Last Commit | ![Last Commit](https://img.shields.io/github/last-commit/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Repository Size | ![Repo Size](https://img.shields.io/github/repo-size/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Code Size | ![Code Size](https://img.shields.io/github/languages/code-size/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Top Language | ![Top Language](https://img.shields.io/github/languages/top/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Language Count | ![Languages](https://img.shields.io/github/languages/count/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Open Issues | ![Issues](https://img.shields.io/github/issues/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Pull Requests | ![Pull Requests](https://img.shields.io/github/issues-pr/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Stars | ![Stars](https://img.shields.io/github/stars/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Forks | ![Forks](https://img.shields.io/github/forks/theentrophyenchelon-svg/WindUi?style=flat-square) |
| Contributors | ![Contributors](https://img.shields.io/github/contributors/theentrophyenchelon-svg/WindUi?style=flat-square) |

---

## Why WindUI GodTier

WindUI GodTier is built to be the best Roblox UI library experience: premium by default, lightweight to use, visually sharp, and flexible enough for serious projects. It is not just a collection of frames and buttons. It is a complete interface layer for polished Roblox experiences.

### Core Focus

- **Premium Visual Identity** — modern spacing, rounded shells, glow layers, refined borders, acrylic styling, and clean hierarchy.
- **Smooth Motion System** — hover states, press states, entrance motion, reduced-motion support, and configurable animation speed.
- **GodTier Theme Layer** — premium presets such as `Aurora`, `Obsidian`, `Cyber`, and `Royal`.
- **Developer-Friendly API** — create windows, tabs, sections, dialogs, notifications, controls, and custom themes quickly.
- **Roblox-Ready Components** — built for Luau, Roblox UI workflows, script hubs, and responsive interface patterns.
- **Expandable Architecture** — clean `src`, `dist`, `components`, `elements`, `themes`, `utils`, and build structure.

---

## Feature Highlights

| Category | Included |
|---|---|
| Windows | Premium shell, radius control, acrylic mode, glow, open button, dialogs, sections, tabs |
| Elements | Button, Toggle, Slider, Dropdown, Input, Keybind, Colorpicker, Paragraph, Divider, Image, Video, Viewport |
| Layout | Groups, HStack, VStack, Space, Sections, scroll controls |
| Feedback | Notifications, popups, ripple interactions, hover and press micro-interactions |
| Themes | Theme engine, presets, custom theme creation, fallbacks |
| Motion | Global animation speed, reduced motion mode, premium pulse behavior |
| Key Systems | Built-in key system components and service integrations |
| Build | Darklua configuration, package build scripts, distribution output |
| Testing | Element stress example with large-scale component rendering |

---

## Installation

### Recommended Loadstring

After `dist/main.lua` is committed and hosted from this repository, use:

```luau
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/dist/main.lua"))()
```

### Example Startup

```luau
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/dist/main.lua"))()

WindUI:UsePreset("GodTier")
WindUI:SetAnimationSpeed(1)
WindUI:SetReducedMotion(false)
WindUI:SetUIScale(1)

local window = WindUI:CreateWindow({
    Title = "WindUI GodTier",
    Icon = "sparkles",
    Author = "Premium Roblox UI Library",
    Theme = "Aurora",
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Premium = true,
    Glow = true,
})

local mainTab = window:Tab({
    Title = "Main",
    Icon = "house",
})

mainTab:Button({
    Title = "Launch Feature",
    Desc = "Runs a premium WindUI interaction.",
    Callback = function()
        WindUI:Notify({
            Title = "WindUI GodTier",
            Content = "Feature launched successfully.",
            Duration = 3,
        })
    end,
})
```

---

## GodTier Upgrade APIs

| API | Purpose |
|---|---|
| `WindUI:SetAnimationSpeed(speed)` | Controls global animation speed. |
| `WindUI:SetReducedMotion(enabled)` | Improves accessibility by reducing motion-heavy effects. |
| `WindUI:SetUIScale(scale)` | Scales the UI globally. |
| `WindUI:CreateTheme(name, themeData)` | Registers a custom theme. |
| `WindUI:UsePreset(name)` | Applies a premium preset such as `GodTier`. |
| `Window:SetRadius(radius)` | Adjusts the main window radius. |
| `Window:SetPremium(enabled)` | Toggles premium window treatment. |
| `Window:Pulse()` | Plays a premium pulse interaction. |

---

## Premium Theme Presets

| Theme | Style Direction |
|---|---|
| `Aurora` | Bright, clean, magical, premium color energy |
| `Obsidian` | Dark, sleek, glassy, high-contrast interface |
| `Cyber` | Futuristic neon interface with tech-inspired polish |
| `Royal` | Elegant, elevated, luxury-style UI treatment |

---

## Project Structure

```text
WindUi/
├── .github/workflows/       # Build, pull request, and release automation
├── build/                   # Darklua and package build tooling
├── dist/                    # Compiled distributable library output
├── docs/                    # Branding, banners, previews, and visual assets
├── src/                     # Main source code
│   ├── components/          # Window, popup, search, notification, and UI components
│   ├── config/              # Configuration modules
│   ├── elements/            # Public UI elements
│   ├── modules/             # Creator, icons, localization, highlighter
│   ├── server/              # Server-side utility integrations
│   ├── themes/              # Theme engine and fallbacks
│   └── utils/               # Acrylic, services, and shared utilities
├── tests/                   # Stress and element tests
├── Example.lua              # Example usage
├── main.lua                 # Entry point
├── main.client.lua          # Client-side example entry
├── main_example.lua         # Example load entry
├── package.json             # Package metadata and scripts
└── GODTIER_UPGRADE.md       # Upgrade summary
```

---

## Component Catalog

### Inputs and Controls

- Button
- Toggle
- Checkbox
- Slider
- Dropdown
- Input
- Keybind
- Colorpicker

### Content and Display

- Label
- Paragraph
- Code
- Image
- Video
- Viewport
- Divider
- Tag
- Tooltip

### Layout and Structure

- Window
- Tab
- Section
- Group
- HStack
- VStack
- Space
- ScrollSlider

### Experience Layer

- Notification
- Popup
- Dialog
- Search
- KeySystem
- Acrylic blur utilities
- Icon libraries

---

## Build Commands

```bash
npm install
npm run build
```

### Development Mode

```bash
npm run dev
```

### Live Build Mode

```bash
npm run live-build
```

### Example Live Build

```bash
npm run example-live-build
```

---

## Roadmap

- [x] Premium motion layer
- [x] Ripple feedback system
- [x] GodTier theme presets
- [x] Premium window shell
- [x] Modern default element styling
- [x] Public animation and theme APIs
- [ ] Complete hosted documentation pass
- [ ] Add full visual preview gallery
- [ ] Add API reference examples for every element
- [ ] Add production-ready demo place examples
- [ ] Add automated release notes and version tagging

---

## Version

Current package version:

```text
1.7.0-godtier
```

---

## Credits

WindUI includes or references icon inspiration and assets from high-quality icon systems:

- [Lucide Icons](https://github.com/lucide-icons/lucide)
- [Craft Icons](https://www.figma.com/community/file/1415718327120418204)
- [Geist Icons](https://vercel.com/geist/icons)
- [Solar Icons](https://icones.js.org/collection/solar)
- [SF Symbols](https://sf-symbols-one.vercel.app/)

Original WindUI ecosystem references:

- [Documentation](https://footagesus.github.io/treehub-web/docs/windui)
- [Installation](https://footagesus.github.io/WindUI-Docs/docs/installation)
- [Discord Server](https://discord.gg/ftgs-development-hub-1300692552005189632)

---

## Notice

WindUI GodTier is currently in active development. The library is intended to provide a polished, premium Roblox UI foundation while continuing to evolve with new themes, components, examples, and documentation.

<div align="center">

## WindUI GodTier

### Premium Roblox UI. Clean API. Elite presentation.

</div>
