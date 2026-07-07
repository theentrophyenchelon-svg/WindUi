--[[
	Sentry Hub Library - Embedded Console Panel
	Streams local runtime messages into the contained Console Log tab.
]]

return function(WindUI, Sentry)
	if type(WindUI) ~= "table" or type(Sentry) ~= "table" then
		return Sentry
	end
	if Sentry.ConsolePanelPatchInstalled then
		return Sentry
	end

	local LogService = game:GetService("LogService")
	local RunService = game:GetService("RunService")

	Sentry.ConsolePanelPatchInstalled = true
	Sentry.ConsoleFilter = "All"
	Sentry.ConsoleCounts = { All = 0, Output = 0, Warning = 0, Error = 0, Info = 0 }
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Console]", result)
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
		if text:find("Warning") then return "Warning" end
		if text:find("Error") then return "Error" end
		if text:find("Info") then return "Info" end
		return "Output"
	end

	function Sentry:AddConsoleLine(level, message)
		self.Logs = self.Logs or {}
		level = tostring(level or "Output")
		local entry = { Time = os.date("%H:%M:%S"), Level = level, Text = tostring(message or "") }
		table.insert(self.Logs, entry)
		if #self.Logs > 180 then table.remove(self.Logs, 1) end
		self.ConsoleCounts.All += 1
		self.ConsoleCounts[level] = (self.ConsoleCounts[level] or 0) + 1
		return entry
	end

	function Sentry:ConsoleText(maxLines)
		maxLines = maxLines or 18
		local rows = {}
		for i = #(self.Logs or {}), 1, -1 do
			local entry = self.Logs[i]
			if self.ConsoleFilter == "All" or entry.Level == self.ConsoleFilter then
				table.insert(rows, 1, ("[%s] %-7s %s"):format(entry.Time, entry.Level, entry.Text))
			end
			if #rows >= maxLines then break end
		end
		return #rows > 0 and table.concat(rows, "\n") or "No console lines for this filter yet."
	end

	function Sentry:ConsoleSummary()
		return "Filter: " .. self.ConsoleFilter .. "\nAll: " .. self.ConsoleCounts.All .. " | Output: " .. self.ConsoleCounts.Output .. " | Info: " .. self.ConsoleCounts.Info .. " | Warnings: " .. self.ConsoleCounts.Warning .. " | Errors: " .. self.ConsoleCounts.Error
	end

	function Sentry:RefreshConsolePanel()
		setParagraph(self.Refs.ConsoleSummary, "Console Diagnostics", self:ConsoleSummary())
		setParagraph(self.Refs.ConsoleStream, "Live Console Stream", self:ConsoleText(18))
	end

	function Sentry:AttachConsolePanel()
		if self.ConsolePanelAttached then return end
		self.ConsolePanelAttached = true
		self.Connections = self.Connections or {}
		local connection = LogService.MessageOut:Connect(function(message, kind)
			self:AddConsoleLine(levelFromType(kind), message)
		end)
		table.insert(self.Connections, connection)
		self:AddConsoleLine("Info", "Console capture connected.")
	end

	function Sentry:BuildConsole(tab)
		if not tab then return end
		self:AttachConsolePanel()
		safe(function() tab:Section({ Title = "Advanced Console Log", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.ConsoleSummary = tab:Paragraph({
				Title = "Console Diagnostics",
				Desc = self:ConsoleSummary(),
				Image = self.Icons.Console or "terminal",
				Color = self.Accent,
				Buttons = {
					{ Title = "All", Icon = "terminal", Callback = function() self.ConsoleFilter = "All" self:RefreshConsolePanel() end },
					{ Title = "Warnings", Icon = "triangle-alert", Callback = function() self.ConsoleFilter = "Warning" self:RefreshConsolePanel() end },
					{ Title = "Errors", Icon = "circle-x", Callback = function() self.ConsoleFilter = "Error" self:RefreshConsolePanel() end },
				},
			})
		end)
		safe(function()
			self.Refs.ConsoleStream = tab:Paragraph({
				Title = "Live Console Stream",
				Desc = self:ConsoleText(18),
				Image = self.Icons.Console or "terminal",
				Color = self.Accent,
				Buttons = {
					{ Title = "Test Print", Icon = "terminal", Callback = function() print("Sentry console print test") task.defer(function() self:RefreshConsolePanel() end) end },
					{ Title = "Test Warn", Icon = "triangle-alert", Callback = function() warn("Sentry console warning test") task.defer(function() self:RefreshConsolePanel() end) end },
				},
			})
		end)
		safe(function() tab:Section({ Title = "Console Notes", TextSize = 20, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Input({ Title = "Add Note", Placeholder = "Write a console note...", Callback = function(value) self:AddConsoleLine("Info", tostring(value)) self:RefreshConsolePanel() end })
		end)
	end

	function Sentry:StartConsolePanelLoop()
		if self.ConsolePanelLoop then return end
		local last = 0
		self.ConsolePanelLoop = RunService.RenderStepped:Connect(function()
			local now = os.clock()
			if now - last >= 1 then
				last = now
				self:RefreshConsolePanel()
			end
		end)
		self.Connections = self.Connections or {}
		table.insert(self.Connections, self.ConsolePanelLoop)
	end

	return Sentry
end
