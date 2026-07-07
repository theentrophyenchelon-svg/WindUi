--[[
	Sentry Hub Library - Profile Viewport Patch
	Uses the built-in Viewport element for an embedded avatar profile panel.
]]

return function(WindUI, Sentry)
	if type(WindUI) ~= "table" or type(Sentry) ~= "table" then
		return Sentry
	end
	if Sentry.ProfileViewportPatchInstalled then
		return Sentry
	end

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	Sentry.ProfileViewportPatchInstalled = true
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Profile = Sentry.Icons.Profile or "circle-user-round"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Profile]", result)
		return nil
	end

	function Sentry:ProfilePanel(tab)
		if not tab or not LocalPlayer then return end

		safe(function()
			tab:Section({ Title = "Player Profile", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		safe(function()
			local model = Players:CreateHumanoidModelFromUserId(LocalPlayer.UserId)
			model.Name = "SentryProfileAvatar"
			model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))

			self.Refs.ProfileViewport = tab:Viewport({
				Object = model,
				Height = 230,
				Interactive = true,
				Focused = true,
			})
		end)

		safe(function()
			self.Refs.Profile = tab:Paragraph({
				Title = LocalPlayer.DisplayName .. "  @" .. LocalPlayer.Name,
				Desc = "Account ID: " .. LocalPlayer.UserId .. "\nAccount Age: " .. LocalPlayer.AccountAge .. " days\nInteractive avatar viewport is embedded inside Sentry.",
				Image = self.Icons.Profile,
				Color = self.Accent,
			})
		end)
	end

	return Sentry
end
