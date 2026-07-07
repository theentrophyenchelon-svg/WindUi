# WindUI GodTier Upgrade

This package was upgraded in-place for a more premium Roblox Luau UI library experience.

## Major upgrades

- Premium motion layer: global animation speed, reduced motion, hover/press micro-interactions.
- Ripple feedback system for buttons, tabs, and element rows.
- Higher-end window shell: larger radius, refined spacing, glow layer, border stroke, stronger open/close animation.
- Modern defaults: `NewElements` is now enabled unless explicitly set to `false`.
- New public APIs: `WindUI:SetAnimationSpeed`, `WindUI:SetReducedMotion`, `WindUI:SetUIScale`, `WindUI:CreateTheme`, `WindUI:UsePreset`.
- New window APIs: `Window:SetRadius`, `Window:SetPremium`, `Window:Pulse`.
- New premium themes: `Aurora`, `Obsidian`, `Cyber`, and `Royal`.

## Recommended startup

```lua
local WindUI = loadstring(game:HttpGet("YOUR_HOSTED_DIST_MAIN_LUA"))()
WindUI:UsePreset("GodTier")

local Window = WindUI:CreateWindow({
    Title = "Konquest Combat",
    Icon = "sparkles",
    Author = "Ultimate UI System",
    Theme = "Aurora",
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Premium = true,
    Glow = true,
})
```

## Compatibility

Old configs should still work. To force the previous grouped element look, set `NewElements = false` in `CreateWindow`.
