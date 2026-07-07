--[[
	Sentry Hub Library Production Showcase
	Run this in a LocalScript or Roblox Studio command bar with HTTP requests enabled.
]]

local REPO = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(REPO .. "dist/main.lua"))()

local installProduction
local okProduction = pcall(function()
	installProduction = loadstring(game:HttpGet(REPO .. "dist/sentry_production.lua"))()
end)

local SentryHub
if okProduction and type(installProduction) == "function" then
	SentryHub = installProduction(WindUI)
else
	local installFallback = loadstring(game:HttpGet(REPO .. "dist/godtier_plus.lua"))()
	SentryHub = installFallback(WindUI)
end

if SentryHub then
	pcall(function()
		local installProfileViewport = loadstring(game:HttpGet(REPO .. "dist/sentry_profile_viewport.lua"))()
		installProfileViewport(WindUI, SentryHub)
	end)

	pcall(function()
		local installConsolePanel = loadstring(game:HttpGet(REPO .. "dist/sentry_console_panel.lua"))()
		installConsolePanel(WindUI, SentryHub)
	end)

	pcall(function()
		local installCleanFix = loadstring(game:HttpGet(REPO .. "dist/sentry_clean_fix.lua"))()
		installCleanFix(WindUI, SentryHub)
	end)

	pcall(function()
		local installThemeRestore = loadstring(game:HttpGet(REPO .. "dist/sentry_theme_restore.lua"))()
		installThemeRestore(WindUI, SentryHub)
	end)

	pcall(function()
		local installSettings = loadstring(game:HttpGet(REPO .. "dist/sentry_settings_simple.lua"))()
		installSettings(WindUI, SentryHub)
	end)

	pcall(function()
		local installActions = loadstring(game:HttpGet(REPO .. "dist/sentry_actions_tab.lua"))()
		installActions(WindUI, SentryHub)
	end)
end

if SentryHub and SentryHub.BuildShowcase then
	SentryHub:BuildShowcase()
	pcall(function()
		if SentryHub.StartConsolePanelLoop then
			SentryHub:StartConsolePanelLoop()
		end
		if SentryHub.StartCleanFixLoop then
			SentryHub:StartCleanFixLoop()
		end
	end)
else
	local Window = WindUI:CreateWindow({
		Title = "Sentry Hub Library",
		Icon = "shield-check",
		Author = "Production Roblox UI Framework",
		Theme = "Dark",
		Size = UDim2.fromOffset(700, 560),
		Acrylic = true,
		NewElements = true,
	})

	local MainTab = Window:Tab({
		Title = "Main",
		Desc = "Fallback showcase",
		Icon = "home",
		Border = true,
	})

	MainTab:Paragraph({
		Title = "Sentry Hub Library loaded",
		Desc = "The base UI is running. Production layer failed to install, so fallback mode loaded instead.",
	})
end
