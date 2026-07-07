--[[
	Sentry Hub Library - Clean Fix Pack
	Root override for console, friends, themes, settings, about, and final showcase layout.
]]

return function(WindUI, Sentry)
	if type(WindUI) ~= "table" or type(Sentry) ~= "table" then
		return Sentry
	end
	if Sentry.CleanFixInstalled then
		return Sentry
	end

	local Players = game:GetService("Players")
	local LogService = game:GetService("LogService")
	local RunService = game:GetService("RunService")
	local TeleportService = game:GetService("TeleportService")
	local LocalPlayer = Players.LocalPlayer

	Sentry.CleanFixInstalled = true
	Sentry.Accent = Color3.fromRGB(185, 190, 205)
	Sentry.Theme = "Dark"
	Sentry.ConsoleFilter = "All"
	Sentry.DevConsoleLines = {}
	Sentry.ConsoleCounts = { All = 0, Output = 0, Info = 0, Warning = 0, Error = 0 }
	Sentry.OnlineFriendTargets = {}
	Sentry.OnlineFriendRows = {}
	Sentry.RegisteredScripts = Sentry.RegisteredScripts or {}
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Console = Sentry.Icons.Console or "terminal"
	Sentry.Icons.Friends = Sentry.Icons.Friends or "users"
	Sentry.Icons.Refresh = Sentry.Icons.Refresh or "refresh-cw"
	Sentry.Icons.Copy = Sentry.Icons.Copy or "copy"
	Sentry.Icons.Join = Sentry.Icons.Join or "log-in"
	Sentry.Icons.Script = Sentry.Icons.Script or "scroll-text"
	Sentry.Icons.Server = Sentry.Icons.Server or "server"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return true, result end
		warn("[Sentry Fix]", result)
		return false, result
	end

	local function notify(kind, title, content, duration)
		local method = WindUI.NotifyInfo
		if kind == "Success" then method = WindUI.NotifySuccess end
		if kind == "Warning" then method = WindUI.NotifyWarning end
		if kind == "Error" then method = WindUI.NotifyError end
		if method then return pcall(function() method(WindUI, title, content, duration or 3) end) end
		return pcall(function() WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 }) end)
	end

	local function setParagraph(paragraph, title, desc)
		if type(paragraph) ~= "table" then return end
		local frame = paragraph.ParagraphFrame
		local elements = frame and frame.UIElements
		if elements then
			if title and elements.Title then elements.Title.Text = title elements.Title.Visible = true end
			if desc and elements.Desc then elements.Desc.Text = desc elements.Desc.Visible = true end
		end
	end

	local function levelFromType(kind)
		local text = tostring(kind or "")
		if text:find("Error") then return "Error" end
		if text:find("Warning") then return "Warning" end
		if text:find("Info") then return "Info" end
		return "Output"
	end

	function Sentry:AddDevConsoleLine(level, message)
		level = tostring(level or "Output")
		local line = { Time = os.date("%H:%M:%S"), Level = level, Message = tostring(message or "") }
		table.insert(self.DevConsoleLines, line)
		if #self.DevConsoleLines > 350 then table.remove(self.DevConsoleLines, 1) end
		self.ConsoleCounts.All += 1
		self.ConsoleCounts[level] = (self.ConsoleCounts[level] or 0) + 1
		return line
	end

	function Sentry:LoadDevConsoleHistory()
		local ok, history = safe(function() return LogService:GetLogHistory() end)
		if not ok or type(history) ~= "table" then
			self:AddDevConsoleLine("Info", "Log history is unavailable; capturing new client output from this point forward.")
			return
		end
		for _, entry in ipairs(history) do
			local message = entry.message or entry.Message or entry.text or entry.Text or tostring(entry)
			local level = levelFromType(entry.messageType or entry.MessageType or entry.type or entry.Type)
			self:AddDevConsoleLine(level, message)
		end
		self:AddDevConsoleLine("Info", "Loaded " .. tostring(#history) .. " existing dev-console entries.")
	end

	function Sentry:AttachFullDevConsoleCapture()
		if self.FullDevConsoleAttached then return end
		self.FullDevConsoleAttached = true
		self:LoadDevConsoleHistory()
		self.Connections = self.Connections or {}
		local connection = LogService.MessageOut:Connect(function(message, kind)
			self:AddDevConsoleLine(levelFromType(kind), message)
		end)
		table.insert(self.Connections, connection)
	end

	function Sentry:FullConsoleText(maxLines)
		maxLines = maxLines or 55
		local rows = {}
		for i = #self.DevConsoleLines, 1, -1 do
			local entry = self.DevConsoleLines[i]
			if self.ConsoleFilter == "All" or entry.Level == self.ConsoleFilter then
				table.insert(rows, 1, ("[%s] %-7s %s"):format(entry.Time, entry.Level, entry.Message))
			end
			if #rows >= maxLines then break end
		end
		return #rows > 0 and table.concat(rows, "\n") or "No dev-console output found for this filter yet."
	end

	function Sentry:FullConsoleSummary()
		return "Filter: " .. self.ConsoleFilter .. "\nAll: " .. self.ConsoleCounts.All .. " | Output: " .. self.ConsoleCounts.Output .. " | Info: " .. self.ConsoleCounts.Info .. " | Warnings: " .. self.ConsoleCounts.Warning .. " | Errors: " .. self.ConsoleCounts.Error .. "\nMode: Full dev-console history where available + live Roblox client output."
	end

	function Sentry:RefreshFullConsole()
		setParagraph(self.Refs.ConsoleSummary, "Dev Console Diagnostics", self:FullConsoleSummary())
		setParagraph(self.Refs.ConsoleStream, "Full Dev Console Output", self:FullConsoleText(55))
	end

	function Sentry:BuildConsole(tab)
		if not tab then return end
		self:AttachFullDevConsoleCapture()
		pcall(function() tab:Section({ Title = "Roblox Dev Console", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function()
			self.Refs.ConsoleSummary = tab:Paragraph({ Title = "Dev Console Diagnostics", Desc = self:FullConsoleSummary(), Image = self.Icons.Console, Buttons = {
				{ Title = "All", Icon = "terminal", Callback = function() self.ConsoleFilter = "All" self:RefreshFullConsole() end },
				{ Title = "Warnings", Icon = "triangle-alert", Callback = function() self.ConsoleFilter = "Warning" self:RefreshFullConsole() end },
				{ Title = "Errors", Icon = "circle-x", Callback = function() self.ConsoleFilter = "Error" self:RefreshFullConsole() end },
			} })
		end)
		pcall(function()
			self.Refs.ConsoleStream = tab:Paragraph({ Title = "Full Dev Console Output", Desc = self:FullConsoleText(55), Image = self.Icons.Console, Buttons = {
				{ Title = "Refresh", Icon = self.Icons.Refresh, Callback = function() self:RefreshFullConsole() end },
				{ Title = "Test Print", Icon = "terminal", Callback = function() print("Sentry dev console print test") task.defer(function() self:RefreshFullConsole() end) end },
				{ Title = "Copy", Icon = self.Icons.Copy, Callback = function() if setclipboard then setclipboard(self:FullConsoleText(120)) end end },
			} })
		end)
		pcall(function() tab:Section({ Title = "Console Notes", TextSize = 20, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Input({ Title = "Add Note", Placeholder = "Write a console note...", Callback = function(value) self:AddDevConsoleLine("Info", tostring(value)) self:RefreshFullConsole() end }) end)
	end

	function Sentry:ThemeNames()
		return { "Dark", "Light", "Aurora", "Obsidian", "Cyber", "Royal", "Velvet", "Glacier", "Solar", "Eclipse", "Crimson", "Emerald" }
	end

	function Sentry:BuildThemes(tab, window)
		if not tab then return end
		pcall(function() tab:Section({ Title = "Theme Studio", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() self.Refs.ThemeStatus = tab:Paragraph({ Title = "Theme System", Desc = "All themes are restored using Sentry's clean transparent/default styling.", Image = self.Icons.Themes }) end)
		pcall(function() tab:Section({ Title = "Theme Presets", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function()
			tab:Dropdown({ Title = "Active Theme", Values = self:ThemeNames(), Value = self.Theme or "Dark", Callback = function(value)
				self.Theme = tostring(value)
				pcall(function() self:UseTheme(value) end)
				pcall(function() window:SetTheme(value) end)
				setParagraph(self.Refs.ThemeStatus, "Theme System", "Active Theme: " .. tostring(value))
			end })
		end)
		for _, name in ipairs(self:ThemeNames()) do
			pcall(function() tab:Button({ Title = "Apply " .. name, Desc = "Switch to " .. name .. ".", Icon = self.Icons.Themes, Callback = function()
				self.Theme = name
				pcall(function() self:UseTheme(name) end)
				pcall(function() window:SetTheme(name) end)
				setParagraph(self.Refs.ThemeStatus, "Theme System", "Active Theme: " .. name)
			end }) end)
		end
	end

	function Sentry:GetFriendTotals()
		local result = { Total = 0, InServer = {}, Error = nil }
		if not LocalPlayer then result.Error = "No local player" return result end
		local friendIds = {}
		local ok, pages = pcall(function() return Players:GetFriendsAsync(LocalPlayer.UserId) end)
		if not ok or not pages then result.Error = tostring(pages) return result end
		local guard = 0
		while true do
			guard += 1
			local page = {}
			pcall(function() page = pages:GetCurrentPage() end)
			for _, friend in ipairs(page) do
				local id = tonumber(friend.Id or friend.UserId)
				if id then friendIds[id] = true end
				result.Total += 1
			end
			if pages.IsFinished or guard >= 20 then break end
			if not pcall(function() pages:AdvanceToNextPageAsync() end) then break end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and friendIds[player.UserId] then table.insert(result.InServer, { UserId = player.UserId, Username = player.Name, DisplayName = player.DisplayName }) end
		end
		return result
	end

	function Sentry:GetOnlineFriendPresence()
		if not LocalPlayer then return {}, "No local player" end
		local ok, friends = pcall(function() return LocalPlayer:GetFriendsOnline(200) end)
		if not ok then return {}, tostring(friends) end
		local result = {}
		for _, friend in ipairs(friends or {}) do
			local placeId = tonumber(friend.PlaceId or friend.PlaceID)
			local jobId = friend.GameId or friend.GameID or friend.JobId or friend.JobID
			if jobId == "" then jobId = nil end
			table.insert(result, { UserId = tonumber(friend.VisitorId or friend.UserId or friend.Id), Username = tostring(friend.UserName or friend.Username or friend.Name or "Unknown"), DisplayName = tostring(friend.DisplayName or friend.UserName or friend.Username or "Unknown"), LastLocation = tostring(friend.LastLocation or friend.Location or "Unknown location"), PlaceId = placeId, JobId = jobId })
		end
		return result, nil
	end

	function Sentry:FriendRowText(friend, index)
		if not friend then return "Waiting for Roblox online presence data for slot " .. index .. "." end
		return "Username: @" .. friend.Username .. "\nDisplay Name: " .. friend.DisplayName .. "\nLocation: " .. friend.LastLocation .. "\nPlace ID: " .. tostring(friend.PlaceId or "Not exposed") .. "\nServer Job ID: " .. tostring(friend.JobId or "Not exposed") .. "\nJoin: " .. (friend.PlaceId and "Available" or "Unavailable")
	end

	function Sentry:FriendSummaryText()
		local totals = self:GetFriendTotals()
		local online, err = self:GetOnlineFriendPresence()
		self.OnlineFriendTargets = online
		local publicTargets = 0
		for _, friend in ipairs(online) do if friend.PlaceId then publicTargets += 1 end end
		local lines = { "Total Friends: " .. totals.Total, "Friends in Server: " .. #totals.InServer, "Presence Online Count: " .. #online, "Public Join Targets: " .. publicTargets }
		if totals.Error then table.insert(lines, "Friend Count Diagnostics: " .. totals.Error) end
		if err then table.insert(lines, "Presence Diagnostics: " .. err) end
		return table.concat(lines, "\n")
	end

	function Sentry:RefreshFriendPresencePanel()
		setParagraph(self.Refs.Friends, "Friend System", self:FriendSummaryText())
		for i = 1, 15 do
			local friend = self.OnlineFriendTargets[i]
			local row = self.OnlineFriendRows[i]
			local title = friend and (friend.DisplayName .. "  @" .. friend.Username) or ("Online Friend Slot " .. i)
			setParagraph(row, title, self:FriendRowText(friend, i))
		end
	end

	function Sentry:JoinOnlineFriend(index)
		local friend = self.OnlineFriendTargets[index]
		if not friend then notify("Warning", "No Friend", "No online friend is assigned to this slot yet. Press Refresh first.", 3) return end
		if not friend.PlaceId then notify("Warning", "Join Limited", "Roblox did not expose a joinable place for " .. friend.DisplayName .. ".", 4) return end
		notify("Info", "Joining Friend", "Trying to join " .. friend.DisplayName .. "...", 3)
		local ok, err = false, nil
		if friend.JobId then
			ok, err = safe(function() TeleportService:TeleportToPlaceInstance(friend.PlaceId, tostring(friend.JobId), LocalPlayer) end)
		end
		if not ok then ok, err = safe(function() TeleportService:Teleport(friend.PlaceId, LocalPlayer) end) end
		if not ok then notify("Error", "Join Failed", tostring(err or "Roblox blocked the teleport or the session is unavailable."), 5) end
	end

	function Sentry:BuildFriends(tab)
		if not tab then return end
		pcall(function() tab:Section({ Title = "Friend System", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() self.Refs.Friends = tab:Paragraph({ Title = "Friend System", Desc = self:FriendSummaryText(), Image = self.Icons.Friends, Buttons = { { Title = "Refresh", Icon = self.Icons.Refresh, Callback = function() self:RefreshFriendPresencePanel() end } } }) end)
		pcall(function() tab:Section({ Title = "Online Friends", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		self.OnlineFriendRows = {}
		for i = 1, 15 do
			pcall(function() self.OnlineFriendRows[i] = tab:Paragraph({ Title = "Online Friend Slot " .. i, Desc = self:FriendRowText(self.OnlineFriendTargets[i], i), Image = self.Icons.Friends, Buttons = { { Title = "Join", Icon = self.Icons.Join, Callback = function() self:JoinOnlineFriend(i) end } } }) end)
		end
		self:RefreshFriendPresencePanel()
	end

	function Sentry:FriendText()
		return self:FriendSummaryText()
	end

	function Sentry:RefreshFriendPanels()
		self:RefreshFriendPresencePanel()
	end

	function Sentry:RegisterScript(config)
		config = config or {}
		local action = { Name = tostring(config.Name or config.Title or ("Script " .. tostring(#self.RegisteredScripts + 1))), Description = tostring(config.Description or "Registered developer script."), Icon = config.Icon or self.Icons.Script, Run = config.Run or config.Callback }
		table.insert(self.RegisteredScripts, action)
		return action
	end

	function Sentry:SeedScriptHub()
		if self.ScriptHubSeeded then return end
		self.ScriptHubSeeded = true
		self:RegisterScript({ Name = "Print Runtime Status", Description = "Prints Sentry runtime status to the console.", Run = function() print("Sentry active", self.Version, self.Theme) end })
		self:RegisterScript({ Name = "Refresh Console", Description = "Refreshes the contained console panel.", Run = function() if self.RefreshFullConsole then self:RefreshFullConsole() elseif self.RefreshConsolePanel then self:RefreshConsolePanel() end end })
		self:RegisterScript({ Name = "Refresh Friends", Description = "Refreshes the friend presence panel.", Run = function() if self.RefreshFriendPresencePanel then self:RefreshFriendPresencePanel() end end })
	end

	function Sentry:BuildScriptHub(tab)
		if not tab then return end
		self:SeedScriptHub()
		pcall(function() tab:Section({ Title = "Script Hub", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Paragraph({ Title = "ScriptBox API System", Desc = "A safe developer-script registry for your own experience. Register scripts with SentryHub:RegisterScript({ Name, Description, Run }).", Image = self.Icons.Script }) end)
		pcall(function() tab:Section({ Title = "Registered Scripts", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		for _, action in ipairs(self.RegisteredScripts) do
			pcall(function() tab:Paragraph({ Title = action.Name, Desc = action.Description, Image = action.Icon, Buttons = { { Title = "Run", Icon = "play", Callback = function() if type(action.Run) == "function" then local ok, err = safe(action.Run) if ok then notify("Success", "Script Hub", "Ran " .. action.Name, 2) else notify("Error", "Script Failed", tostring(err), 4) end end end } } }) end)
		end
	end

	function Sentry:BuildSettings(tab)
		if not tab then return end
		pcall(function() tab:Section({ Title = "Session Settings", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Paragraph({ Title = "Server Tools", Desc = "Rejoin reloads the current place. Server Hop asks Roblox to place you into a public server for this experience.", Image = self.Icons.Server, Buttons = { { Title = "Rejoin", Icon = self.Icons.Refresh, Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end }, { Title = "Server Hop", Icon = self.Icons.Server, Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end } } }) end)
		pcall(function() tab:Section({ Title = "Interface Settings", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Dropdown({ Title = "Motion Profile", Values = { "Cinematic", "Balanced", "Snappy", "Reduced" }, Value = "Balanced", Callback = function(value) if self.SetMotionProfile then self:SetMotionProfile(value) end end }) end)
		pcall(function() tab:Button({ Title = "Refresh Console", Desc = "Refresh the contained console panel.", Icon = self.Icons.Refresh, Callback = function() if self.RefreshFullConsole then self:RefreshFullConsole() elseif self.RefreshConsolePanel then self:RefreshConsolePanel() end end }) end)
		pcall(function() tab:Button({ Title = "Refresh Friends", Desc = "Refresh the friend presence panel.", Icon = self.Icons.Refresh, Callback = function() if self.RefreshFriendPresencePanel then self:RefreshFriendPresencePanel() end end }) end)
	end

	function Sentry:BuildAbout(tab)
		if not tab then return end
		pcall(function() tab:Section({ Title = "About Sentry Hub Library", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold }) end)
		pcall(function() tab:Paragraph({ Title = "What Sentry Hub Library Is", Desc = "Sentry Hub Library is a production-focused Roblox Luau interface framework built on top of a compatible WindUI runtime. It is designed for polished in-experience dashboards, admin panels, settings menus, diagnostics tools, script registries, character menus, and premium game interfaces that need to feel clean, stable, responsive, and finished.", Image = self.Icons.Shield }) end)
		pcall(function() tab:Paragraph({ Title = "Design Philosophy", Desc = "Sentry prioritizes contained UI systems instead of scattered floating windows. The interface is organized into tabs, sections, paragraphs, inputs, dropdowns, buttons, viewports, notifications, and diagnostics so everything feels consistent and professional.", Image = self.Icons.Settings }) end)
		pcall(function() tab:Paragraph({ Title = "Production Features", Desc = "The production layer includes an embedded avatar viewport, full Roblox dev-console display, friend presence diagnostics, restored theme presets, session controls, motion profiles, notifications, a ScriptBox-style developer registry, and compatibility aliases for older Sentry/GodTier builds.", Image = "info" }) end)
	end

	function Sentry:BuildShowcase()
		self.Live = true
		if self.SetMotionProfile then self:SetMotionProfile("Balanced") end
		if self.UseTheme then self:UseTheme(self.Theme or "Dark") end
		if self.IntroBlocking then self:IntroBlocking({ StepDelay = 0.42, Hold = 0.45 }) end
		local window = self:CreateWindow()
		if not window then return nil end
		local main = select(2, safe(function() return window:Tab({ Title = "Main", Desc = "Profile + status", Icon = self.Icons.Home, Border = true }) end))
		local elements = select(2, safe(function() return window:Tab({ Title = "Elements", Desc = "Controls", Icon = self.Icons.Elements, Border = true }) end))
		local themes = select(2, safe(function() return window:Tab({ Title = "Themes", Desc = "Presets", Icon = self.Icons.Themes, Border = true }) end))
		local consoleTab = select(2, safe(function() return window:Tab({ Title = "Console Log", Desc = "Dev output", Icon = self.Icons.Console, Border = true }) end))
		local friends = select(2, safe(function() return window:Tab({ Title = "Friends", Desc = "Presence", Icon = self.Icons.Friends, Border = true }) end))
		local scriptHub = select(2, safe(function() return window:Tab({ Title = "Script Hub", Desc = "ScriptBox", Icon = self.Icons.Script, Border = true }) end))
		local settings = select(2, safe(function() return window:Tab({ Title = "Settings", Desc = "Options", Icon = self.Icons.Settings, Border = true }) end))
		local about = select(2, safe(function() return window:Tab({ Title = "About", Desc = "Info", Icon = "info", Border = true }) end))
		if self.BuildMain then self:BuildMain(main) end
		if self.BuildElements then self:BuildElements(elements) end
		self:BuildThemes(themes, window)
		self:BuildConsole(consoleTab)
		self:BuildFriends(friends)
		self:BuildScriptHub(scriptHub)
		self:BuildSettings(settings)
		self:BuildAbout(about)
		if self.StartLiveLoops then self:StartLiveLoops(window) end
		notify("Success", "Sentry Hub Library", "Refined showcase loaded.", 3)
		return window
	end

	function Sentry:StartCleanFixLoop()
		if self.CleanFixLoop then return end
		local lastConsole = 0
		self.CleanFixLoop = RunService.RenderStepped:Connect(function()
			local now = os.clock()
			if now - lastConsole >= 1 then
				lastConsole = now
				self:RefreshFullConsole()
			end
		end)
		self.Connections = self.Connections or {}
		table.insert(self.Connections, self.CleanFixLoop)
	end

	return Sentry
end
