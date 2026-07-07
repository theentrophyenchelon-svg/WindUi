--[[
	Sentry Hub Library Showcase
	Run this in a LocalScript or Roblox Studio command bar with HTTP requests enabled.
]]

local REPO = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(REPO .. "dist/main.lua"))()
local InstallSentryHub = loadstring(game:HttpGet(REPO .. "dist/godtier_plus.lua"))()

local SentryHub = InstallSentryHub(WindUI)

if SentryHub and SentryHub.BuildShowcase then
	SentryHub:BuildShowcase()
else
	local Window = WindUI:CreateWindow({
		Title = "Sentry Hub Library",
		Icon = "shield-check",
		Author = "Premium Roblox UI Framework",
		Theme = "Aurora",
		Size = UDim2.fromOffset(640, 520),
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
		Desc = "The premium UI framework is running. The enhanced extension layer could not be installed, so the base UI fallback loaded instead.",
	})
end
