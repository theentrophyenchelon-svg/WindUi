--[[
	WindUI GodTier Showcase
	Run this in a LocalScript or Roblox Studio command bar with HTTP requests enabled.
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/dist/main.lua"))()

pcall(function()
	WindUI:UsePreset("GodTier")
	WindUI:SetAnimationSpeed(1)
	WindUI:SetReducedMotion(false)
	WindUI:SetUIScale(1)
end)

local currentTheme = "Aurora"

local Window = WindUI:CreateWindow({
	Title = "WindUI GodTier",
	Icon = "sparkles",
	Author = "Premium Roblox UI Library",
	Folder = "WindUI-GodTier",
	Theme = currentTheme,
	Size = UDim2.fromOffset(640, 520),
	Acrylic = true,
	Premium = true,
	Glow = true,
	NewElements = true,
	HideSearchBar = false,
	ToggleKey = Enum.KeyCode.RightControl,
	OpenButton = {
		Title = "Open WindUI",
		Enabled = true,
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.55,
	},
})

pcall(function()
	Window:Tag({
		Title = "v" .. tostring(WindUI.Version or "1.7.0-godtier"),
		Icon = "github",
		Color = Color3.fromHex("#30FF6A"),
		Border = true,
	})
end)

local function notify(title, content)
	WindUI:Notify({
		Title = title or "WindUI GodTier",
		Content = content or "Action complete.",
		Duration = 3,
	})
end

-- Main Tab
local MainTab = Window:Tab({
	Title = "Main",
	Desc = "Overview and quick actions",
	Icon = "solar:home-2-bold",
	Border = true,
})

MainTab:Section({
	Title = "Welcome to WindUI GodTier",
	TextSize = 24,
	FontWeight = Enum.FontWeight.SemiBold,
})

MainTab:Paragraph({
	Title = "Premium Roblox UI Library",
	Desc = "A clean, cinematic, theme-ready interface library built for polished Roblox menus, tools, dashboards, and in-game systems.",
})

MainTab:Button({
	Title = "Send Test Notification",
	Desc = "Shows the notification system.",
	Icon = "bell",
	Callback = function()
		notify("WindUI GodTier", "The notification system is working perfectly.")
	end,
})

MainTab:Button({
	Title = "Pulse Window",
	Desc = "Runs a premium pulse effect if supported by the current build.",
	Icon = "sparkles",
	Callback = function()
		pcall(function()
			Window:Pulse()
		end)
		notify("Pulse", "Window pulse triggered.")
	end,
})

-- Elements Tab
local ElementsTab = Window:Tab({
	Title = "Elements",
	Desc = "Buttons, toggles, sliders, dropdowns, inputs, and color tools",
	Icon = "solar:widget-5-bold",
	Border = true,
})

ElementsTab:Section({
	Title = "Core Elements",
	TextSize = 22,
	FontWeight = Enum.FontWeight.SemiBold,
})

ElementsTab:Button({
	Title = "Premium Button",
	Desc = "A clean button with callback feedback.",
	Icon = "mouse-pointer-click",
	Callback = function()
		notify("Button", "Premium button clicked.")
	end,
})

ElementsTab:Toggle({
	Title = "GodTier Toggle",
	Desc = "Toggle state feedback example.",
	Default = true,
	Callback = function(value)
		notify("Toggle", "GodTier Toggle is now " .. tostring(value))
	end,
})

ElementsTab:Slider({
	Title = "Animation Speed",
	Desc = "Adjust global animation speed.",
	Value = {
		Min = 0.5,
		Max = 2,
		Default = 1,
	},
	Step = 0.1,
	Callback = function(value)
		pcall(function()
			WindUI:SetAnimationSpeed(value)
		end)
	end,
})

ElementsTab:Dropdown({
	Title = "Power Selection",
	Desc = "Dropdown showcase element.",
	Values = { "Chaos", "Acrylic", "Aurora", "Obsidian", "Cyber", "Royal" },
	Value = "Aurora",
	Callback = function(option)
		notify("Dropdown", "Selected: " .. tostring(option))
	end,
})

ElementsTab:Input({
	Title = "Text Input",
	Desc = "Type anything and submit it.",
	Placeholder = "Enter text here...",
	Callback = function(text)
		notify("Input", "You typed: " .. tostring(text))
	end,
})

ElementsTab:Keybind({
	Title = "Quick Keybind",
	Desc = "Press the bound key to trigger a notification.",
	Value = Enum.KeyCode.G,
	Callback = function()
		notify("Keybind", "Keybind fired.")
	end,
})

ElementsTab:Colorpicker({
	Title = "Accent Color",
	Desc = "Pick a color for visual testing.",
	Default = Color3.fromHex("#30FF6A"),
	Callback = function(color)
		notify("Colorpicker", "Selected color: " .. tostring(color))
	end,
})

-- Themes Tab
local ThemesTab = Window:Tab({
	Title = "Themes",
	Desc = "Switch between premium theme presets",
	Icon = "palette",
	Border = true,
})

ThemesTab:Section({
	Title = "Theme Presets",
	TextSize = 22,
	FontWeight = Enum.FontWeight.SemiBold,
})

ThemesTab:Paragraph({
	Title = "Premium Themes",
	Desc = "Use this tab to test Aurora, Obsidian, Cyber, Royal, Dark, and Light styling inside the same window.",
})

local themeOptions = { "Aurora", "Obsidian", "Cyber", "Royal", "Dark", "Light" }

ThemesTab:Dropdown({
	Title = "Active Theme",
	Desc = "Choose a theme preset.",
	Values = themeOptions,
	Value = currentTheme,
	Callback = function(themeName)
		currentTheme = tostring(themeName)
		pcall(function()
			WindUI:SetTheme(currentTheme)
		end)
		pcall(function()
			Window:SetTheme(currentTheme)
		end)
		notify("Theme Changed", "Applied theme: " .. currentTheme)
	end,
})

for _, themeName in ipairs(themeOptions) do
	ThemesTab:Button({
		Title = "Apply " .. themeName,
		Desc = "Switch instantly to the " .. themeName .. " theme.",
		Icon = "paintbrush",
		Callback = function()
			currentTheme = themeName
			pcall(function()
				WindUI:SetTheme(themeName)
			end)
			pcall(function()
				Window:SetTheme(themeName)
			end)
			notify("Theme Changed", "Applied theme: " .. themeName)
		end,
	})
end

-- Settings Tab
local SettingsTab = Window:Tab({
	Title = "Settings",
	Desc = "UI tuning and accessibility",
	Icon = "settings",
	Border = true,
})

SettingsTab:Toggle({
	Title = "Reduced Motion",
	Desc = "Turns down motion-heavy effects if supported.",
	Default = false,
	Callback = function(value)
		pcall(function()
			WindUI:SetReducedMotion(value)
		end)
		notify("Reduced Motion", "Reduced motion: " .. tostring(value))
	end,
})

SettingsTab:Slider({
	Title = "UI Scale",
	Desc = "Adjust the global interface scale.",
	Value = {
		Min = 0.75,
		Max = 1.35,
		Default = 1,
	},
	Step = 0.05,
	Callback = function(value)
		pcall(function()
			WindUI:SetUIScale(value)
		end)
	end,
})

SettingsTab:Button({
	Title = "Destroy Window",
	Desc = "Closes and removes the showcase UI.",
	Icon = "trash",
	Callback = function()
		Window:Destroy()
	end,
})

-- About Tab
local AboutTab = Window:Tab({
	Title = "About",
	Desc = "Library information",
	Icon = "info",
	Border = true,
})

AboutTab:Section({
	Title = "About WindUI GodTier",
	TextSize = 24,
	FontWeight = Enum.FontWeight.SemiBold,
})

AboutTab:Paragraph({
	Title = "Built for premium Roblox interfaces",
	Desc = "WindUI GodTier is designed for clean layouts, fast setup, polished interaction feedback, theme-driven styling, and professional menu systems.",
})

AboutTab:Paragraph({
	Title = "Included Systems",
	Desc = "Windows, tabs, sections, buttons, toggles, sliders, dropdowns, inputs, keybinds, colorpickers, notifications, themes, acrylic styling, and motion controls.",
})

AboutTab:Button({
	Title = "Repository",
	Desc = "Copies the GitHub repository URL if clipboard support exists.",
	Icon = "github",
	Callback = function()
		pcall(function()
			setclipboard("https://github.com/theentrophyenchelon-svg/WindUi")
		end)
		notify("Repository", "GitHub URL copied if clipboard is available.")
	end,
})

notify("WindUI GodTier", "Showcase loaded with Main, Elements, Themes, Settings, and About tabs.")
