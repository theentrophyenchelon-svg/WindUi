return function(WindUI, Sentry)
	if type(Sentry) ~= "table" then return Sentry end
	if Sentry.SettingsSimpleInstalled then return Sentry end
	Sentry.SettingsSimpleInstalled = true
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Refresh = Sentry.Icons.Refresh or "refresh-cw"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Settings]", result)
		return nil
	end

	function Sentry:BuildSettings(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Interface Settings", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function() tab:Dropdown({ Title = "Motion Profile", Values = { "Cinematic", "Balanced", "Snappy", "Reduced" }, Value = "Balanced", Callback = function(value) if self.SetMotionProfile then self:SetMotionProfile(value) end end }) end)
		safe(function() tab:Button({ Title = "Refresh Console", Desc = "Refresh the contained console panel.", Icon = self.Icons.Refresh, Callback = function() if self.RefreshFullConsole then self:RefreshFullConsole() elseif self.RefreshConsolePanel then self:RefreshConsolePanel() end end }) end)
		safe(function() tab:Button({ Title = "Refresh Friends", Desc = "Refresh the friend presence panel.", Icon = self.Icons.Refresh, Callback = function() if self.RefreshFriendPresencePanel then self:RefreshFriendPresencePanel() end end }) end)
	end

	return Sentry
end
