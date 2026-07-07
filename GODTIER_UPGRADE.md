# Sentry Hub Library Production Upgrade

Sentry Hub Library is now a production-grade Roblox Luau UI framework layered on top of the compatible WindUI runtime. The public runtime keeps `WindUI` for compatibility, while the production layer exposes Sentry-branded systems and a much stronger showcase experience.

## Version

```text
2.0.0-production
```

## Production systems added

- Production showcase builder: `WindUI:CreateSentryShowcase()`.
- Production window defaults: `WindUI:CreateSentryWindow(config)`.
- Advanced transitions with fade and blur pulse support.
- Advanced intro with animated boot card, progress bar, and startup console text.
- Detailed console log overlay with timestamped Sentry logs.
- Live animated background with gradient motion and soft particles.
- Image background layer for custom visual branding.
- Avatar viewport profile card showing the user's 3D avatar, username, display name, account id, and account age.
- Friend system with total friends, online count, offline count, and friends currently in the same server.
- Advanced key system with premium UI, attempt tracking, callbacks, and fallback demo keys.
- Expanded theme studio with Aurora, Cyber, Eclipse, Glacier, Obsidian, Royal, Solar, Velvet, Dark, and Light compatibility.
- New icon mapping layer for clean reusable icon names.
- Performance overlay with FPS and memory stats.
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

## Production APIs

```lua
WindUI:CreateSentryShowcase()
WindUI:CreateSentryWindow(config)
WindUI:CreateSentryIntro(config)
WindUI:CreateSentryConsole(config)
WindUI:CreateSentryTransition(config)
WindUI:CreateSentryLiveBackground(config)
WindUI:CreateSentryImageBackground(config)
WindUI:CreateSentryAvatarViewport(config)
WindUI:CreateSentryKeySystem(config)
WindUI:GetSentryFriendSummary()
WindUI:SetSentryMotionProfile("Balanced")

WindUI:NotifyInfo(title, content, duration)
WindUI:NotifySuccess(title, content, duration)
WindUI:NotifyWarning(title, content, duration)
WindUI:NotifyError(title, content, duration)
```

## Note on security

The advanced key system is a polished client-side UX layer. For real access control, validate permissions and ownership from the server using RemoteEvents/RemoteFunctions and server-side checks.

## Compatibility

The production layer is additive. It does not replace `dist/main.lua`. The older `dist/godtier_plus.lua` extension remains available as a fallback, and the main showcase loader now attempts `dist/sentry_production.lua` first before falling back.
