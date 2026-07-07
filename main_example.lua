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

if SentryHub and SentryHub.BuildShowcase then
	SentryHub:BuildShowcase()
else
	local Window = WindUI:CreateWindow({
		Title = "Sentry Hub Library",
		Icon = "shield-check",
		Author = "Production Roblox UI Framework",
		Theme = "Aurora",
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
