--[[
	WindUI GodTier Plus Showcase
	Run this in a LocalScript or Roblox Studio command bar with HTTP requests enabled.
]]

local REPO = "https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/"

local WindUI = loadstring(game:HttpGet(REPO .. "dist/main.lua"))()
local InstallGodTierPlus = loadstring(game:HttpGet(REPO .. "dist/godtier_plus.lua"))()

local GodTierPlus = InstallGodTierPlus(WindUI)

if GodTierPlus and GodTierPlus.BuildShowcase then
	GodTierPlus:BuildShowcase()
else
	local Window = WindUI:CreateWindow({
		Title = "WindUI GodTier",
		Icon = "sparkles",
		Author = "Premium Roblox UI Library",
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
		Title = "WindUI loaded",
		Desc = "GodTier Plus could not be installed, but the base UI is running.",
	})
end
