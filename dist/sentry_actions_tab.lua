return function(WindUI, Sentry)
	if type(Sentry) ~= "table" then return Sentry end
	if Sentry.ActionsTabInstalled then return Sentry end
	Sentry.ActionsTabInstalled = true
	Sentry.Actions = Sentry.Actions or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Actions = Sentry.Icons.Actions or "scroll-text"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return true, result end
		warn("[Sentry Actions]", result)
		return false, result
	end

	function Sentry:RegisterAction(config)
		config = config or {}
		local action = {
			Name = tostring(config.Name or config.Title or ("Action " .. tostring(#self.Actions + 1))),
			Description = tostring(config.Description or "Registered developer action."),
			Icon = config.Icon or self.Icons.Actions,
			Run = config.Run or config.Callback,
		}
		table.insert(self.Actions, action)
		return action
	end

	function Sentry:SeedActions()
		if self.ActionsSeeded then return end
		self.ActionsSeeded = true
		self:RegisterAction({ Name = "Print Runtime Status", Description = "Prints current Sentry runtime status to the console.", Run = function() print("Sentry active", self.Version, self.Theme) end })
		self:RegisterAction({ Name = "Refresh Console", Description = "Refreshes the contained console panel.", Run = function() if self.RefreshFullConsole then self:RefreshFullConsole() elseif self.RefreshConsolePanel then self:RefreshConsolePanel() end end })
		self:RegisterAction({ Name = "Refresh Friends", Description = "Refreshes the friend presence panel.", Run = function() if self.RefreshFriendPresencePanel then self:RefreshFriendPresencePanel() end end })
	end

	function Sentry:BuildActionsTab(tab)
		if not tab then return end
		self:SeedActions()
		pcall(function() tab:Section({ Title = "Script Hub", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Paragraph({ Title = "ScriptBox API System", Desc = "A safe developer action registry for your own experience. Register actions with SentryHub:RegisterAction({ Name, Description, Run }).", Image = self.Icons.Actions }) end)
		pcall(function() tab:Section({ Title = "Registered Actions", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		for _, action in ipairs(self.Actions) do
			pcall(function()
				tab:Paragraph({ Title = action.Name, Desc = action.Description, Image = action.Icon, Buttons = { { Title = "Run", Icon = "play", Callback = function() if type(action.Run) == "function" then safe(action.Run) end end } } })
			end)
		end
	end

	return Sentry
end
