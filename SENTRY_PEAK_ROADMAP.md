# Sentry Hub Library Peak Roadmap

This roadmap defines the production path for taking Sentry Hub Library to its maximum state while staying stable, contained, and compatible with Roblox privacy and platform rules.

## Current production base

- `dist/main.lua` is the compatible base UI runtime.
- `dist/sentry_production.lua` is the contained production showcase layer.
- `main_example.lua` loads the production layer first and falls back to the older extension if needed.

## Next core upgrades

### 1. Core mount element

Add a real custom mount element to the base library so advanced UI can be embedded directly into tabs without spawning extra ScreenGuis.

Target API:

```lua
local panel = Tab:Mount({
    Title = "Panel Name",
    Height = 220,
    Callback = function(container)
        -- Create custom Roblox UI objects inside container.
    end,
})
```

This unlocks:

- Embedded Roblox console panel.
- Embedded friend cards.
- Embedded image/background preview cards.
- Embedded advanced profile panels.
- Embedded diagnostics dashboards.

### 2. Avatar viewport element

The source already includes a `Viewport` element. The production showcase should use it directly for the player avatar.

Target API:

```lua
local model = Players:CreateHumanoidModelFromUserId(player.UserId)
Tab:Viewport({
    Object = model,
    Height = 220,
    Interactive = true,
})
```

### 3. Advanced console tab

Use Roblox `LogService.MessageOut` in a contained console tab to show client output, warnings, and errors.

Target features:

- Output, info, warning, and error filters.
- Search input.
- Copy logs.
- Clear logs.
- Error counter.
- Warning counter.
- Timestamped output.
- Source labels.

### 4. Friend presence tab

Use Roblox presence APIs only when Roblox exposes data to the local client.

Target features:

- Total friends.
- Online friends.
- Friends in the current server.
- Public/joinable session indicators.
- Join button only when Roblox exposes valid public join data.
- Clear diagnostics when privacy settings hide join data.

Important: Sentry must not attempt to bypass private sessions, private servers, user privacy settings, or Roblox platform restrictions.

### 5. Theme engine max state

Add full animated theme profiles.

Each theme should include:

- Primary accent.
- Secondary accent.
- Glow color.
- Stroke color.
- Background gradient.
- Animation speed.
- Particle style.
- Button treatment.
- Highlight behavior.

### 6. Production background engine

Add contained background controls:

- Decal/image ID input.
- Preview card.
- Save selected background id.
- Animated gradient mode.
- Low-performance mode.
- Blur/acrylic intensity control.

### 7. Performance layer

Add a diagnostics tab with:

- FPS.
- Memory.
- UI element count.
- Active connections.
- Active tweens.
- Render cost warnings.
- Reduced motion switch.
- Cleanup button.

## Highest-value architecture

The true peak version should be split into these files:

```text
dist/main.lua                     # Base runtime
dist/sentry_production.lua        # Production UI shell
dist/sentry_console.lua           # Console tab extension
dist/sentry_friends.lua           # Friend presence extension
dist/sentry_viewport.lua          # Avatar/profile viewport extension
dist/sentry_themes.lua            # Animated theme engine
dist/sentry_backgrounds.lua       # Background engine
```

The showcase loader should install each extension independently and fail softly if one system is unavailable.

## Security note

Client-side UI can be polished, but real permissions and premium checks must be validated from the server. Do not rely on LocalScript keys for real security.
