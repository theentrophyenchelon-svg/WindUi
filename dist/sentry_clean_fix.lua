--[[
	Sentry Hub Library - Clean Fix Pack
	Fixes console history display, friend presence count, and removes forced green styling.
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
	local LocalPlayer = Players.LocalPlayer

	Sentry.CleanFixInstalled = true
	Sentry.Accent = Color3.fromRGB(185, 190, 205)
	Sentry.Theme = "Dark"
	Sentry.ConsoleFilter = "All"
	Sentry.DevConsoleLines = {}
	Sentry.ConsoleCounts = { All = 0, Output = 0, Info = 0, Warning = 0, Error = 0 }
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Console = Sentry.Icons.Console or "terminal"
	Sentry.Icons.Friends = Sentry.Icons.Friends or "users"
	Sentry.Icons.Refresh = Sentry.Icons.Refresh or "refresh-cw"
	Sentry.Icons.Copy = Sentry.Icons.Copy or "copy"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Fix]", result)
		return nil
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
		local line = {
			Time = os.date("%H:%M:%S"),
			Level = level,
			Message = tostring(message or ""),
		}
		table.insert(self.DevConsoleLines, line)
		if #self.DevConsoleLines > 350 then table.remove(self.DevConsoleLines, 1) end
		self.ConsoleCounts.All += 1
		self.ConsoleCounts[level] = (self.ConsoleCounts[level] or 0) + 1
		return line
	end

	function Sentry:LoadDevConsoleHistory()
		local history = safe(function()
			return LogService:GetLogHistory()
		end)
		if type(history) ~= "table" then
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
		safe(function() tab:Section({ Title = "Roblox Dev Console", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.ConsoleSummary = tab:Paragraph({
				Title = "Dev Console Diagnostics",
				Desc = self:FullConsoleSummary(),
				Image = self.Icons.Console,
				Buttons = {
					{ Title = "All", Icon = "terminal", Callback = function() self.ConsoleFilter = "All" self:RefreshFullConsole() end },
					{ Title = "Warnings", Icon = "triangle-alert", Callback = function() self.ConsoleFilter = "Warning" self:RefreshFullConsole() end },
					{ Title = "Errors", Icon = "circle-x", Callback = function() self.ConsoleFilter = "Error" self:RefreshFullConsole() end },
				},
			})
		end)
		safe(function()
			self.Refs.ConsoleStream = tab:Paragraph({
				Title = "Full Dev Console Output",
				Desc = self:FullConsoleText(55),
				Image = self.Icons.Console,
				Buttons = {
					{ Title = "Refresh", Icon = self.Icons.Refresh, Callback = function() self:RefreshFullConsole() end },
					{ Title = "Test Print", Icon = "terminal", Callback = function() print("Sentry dev console print test") task.defer(function() self:RefreshFullConsole() end) end },
					{ Title = "Copy", Icon = self.Icons.Copy, Callback = function() if setclipboard then setclipboard(self:FullConsoleText(120)) end end },
				},
			})
		end)
		safe(function() tab:Section({ Title = "Console Notes", TextSize = 20, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Input({ Title = "Add Note", Placeholder = "Write a console note...", Callback = function(value) self:AddDevConsoleLine("Info", tostring(value)) self:RefreshFullConsole() end })
		end)
	end

	function Sentry:GetPresenceOnlineCount()
		if not LocalPlayer then return 0, "No local player" end
		local online, err = safe(function()
			return LocalPlayer:GetFriendsOnline(200)
		end)
		if type(online) == "table" then
			return #online, nil
		end
		return 0, tostring(err or "Presence unavailable")
	end

	local oldFriendText = Sentry.FriendText
	function Sentry:FriendText()
		local base = type(oldFriendText) == "function" and oldFriendText(self) or ""
		local count, err = self:GetPresenceOnlineCount()
		local text = base .. "\n\nCorrected Presence Online Count: " .. count
		if err then text ..= "\nPresence Diagnostics: " .. err end
		return text
	end

	function Sentry:BuildThemes(tab, window)
		if not tab then return end
		safe(function() tab:Section({ Title = "Theme Studio", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.ThemeStatus = tab:Paragraph({
				Title = "Original Theme Style",
				Desc = "Theme UI has been reverted to the library's cleaner original aesthetic. No forced green theme cards or heavy custom colors.",
				Image = self.Icons.Themes,
			})
		end)
		safe(function() tab:Section({ Title = "Theme Presets", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Dropdown({
				Title = "Active Theme",
				Values = { "Dark", "Light" },
				Value = "Dark",
				Callback = function(value)
					self.Theme = value
					safe(function() window:SetTheme(value) end)
					setParagraph(self.Refs.ThemeStatus, "Original Theme Style", "Active Theme: " .. tostring(value) .. "\nUsing clean transparent/default library styling.")
				end,
			})
		end)
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
