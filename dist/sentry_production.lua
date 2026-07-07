--[[
	Sentry Hub Library Production Layer
	Contained production UI systems for the compatible WindUI runtime.

	Design rule for this layer:
	- Intro may use a temporary loading ScreenGui before the library appears.
	- After the intro, all systems live inside the Sentry UI tabs.
	- No console/avatar/friend/background utility spawns extra floating clutter windows.
]]

return function(WindUI)
	if type(WindUI) ~= "table" then
		return nil
	end
	if WindUI.SentryProduction and WindUI.SentryProduction.__installed then
		return WindUI.SentryProduction
	end

	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Stats = game:GetService("Stats")

	local LocalPlayer = Players.LocalPlayer

	local Sentry = {
		__installed = true,
		Brand = "Sentry Hub Library",
		Version = "2.2.0-contained-live",
		Accent = Color3.fromHex("#30FF6A"),
		Theme = "Aurora",
		Window = nil,
		Logs = {},
		Connections = {},
		Live = true,
		State = {
			ImageBackgroundId = "0",
			LiveBackground = false,
			ThemeCycle = false,
			LastFriendRefresh = 0,
			LastPerformanceRefresh = 0,
		},
		Refs = {},
		Icons = {
			Shield = "shield-check",
			Home = "home",
			Elements = "boxes",
			Visuals = "sparkles",
			Themes = "palette",
			Settings = "settings",
			Friends = "users",
			Key = "key-round",
			Console = "terminal",
			Profile = "circle-user-round",
			Performance = "activity",
			Image = "image",
			Brush = "paintbrush",
			Bell = "bell",
			Glow = "wand-sparkles",
			Star = "star",
			Refresh = "refresh-cw",
			Copy = "copy",
		},
		Themes = {
			Aurora = { Accent = Color3.fromHex("#30FF6A"), Alt = Color3.fromHex("#7C5CFF"), Label = "green + violet aurora glow" },
			Obsidian = { Accent = Color3.fromHex("#9CA3AF"), Alt = Color3.fromHex("#60A5FA"), Label = "graphite + cold blue glass" },
			Cyber = { Accent = Color3.fromHex("#00E5FF"), Alt = Color3.fromHex("#FF2BD6"), Label = "cyan + neon magenta" },
			Royal = { Accent = Color3.fromHex("#C084FC"), Alt = Color3.fromHex("#FACC15"), Label = "purple + gold luxury" },
			Velvet = { Accent = Color3.fromHex("#FF4D8D"), Alt = Color3.fromHex("#7C3AED"), Label = "rose + violet velvet" },
			Glacier = { Accent = Color3.fromHex("#7DD3FC"), Alt = Color3.fromHex("#A7F3D0"), Label = "ice blue + mint frost" },
			Solar = { Accent = Color3.fromHex("#F97316"), Alt = Color3.fromHex("#FDE047"), Label = "orange + sun gold" },
			Eclipse = { Accent = Color3.fromHex("#818CF8"), Alt = Color3.fromHex("#F472B6"), Label = "indigo + pink eclipse" },
			Crimson = { Accent = Color3.fromHex("#EF4444"), Alt = Color3.fromHex("#F97316"), Label = "red + ember highlight" },
			Emerald = { Accent = Color3.fromHex("#10B981"), Alt = Color3.fromHex("#84CC16"), Label = "green + lime shine" },
		},
		Motion = {
			Cinematic = 0.72,
			Balanced = 1,
			Snappy = 1.28,
			Reduced = 0.55,
		},
	}

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then
			return result
		end
		warn("[Sentry]", result)
		return nil
	end

	local function themeData()
		return Sentry.Themes[Sentry.Theme] or Sentry.Themes.Aurora
	end

	local function notify(kind, title, content, duration)
		local color = ({
			Info = Color3.fromHex("#4D9EFF"),
			Success = Color3.fromHex("#30FF6A"),
			Warning = Color3.fromHex("#FFD166"),
			Error = Color3.fromHex("#FF4D6D"),
		})[kind] or Sentry.Accent

		return safe(function()
			return WindUI:Notify({
				Title = title or Sentry.Brand,
				Content = content or "",
				Desc = content or "",
				Duration = duration or 3,
				Color = color,
				Icon = Sentry.Icons.Shield,
			})
		end)
	end

	local function tween(object, info, props)
		local t = TweenService:Create(object, info, props)
		t:Play()
		return t
	end

	local function paragraphSet(paragraph, title, desc)
		if type(paragraph) ~= "table" then
			return
		end
		paragraph.Title = title or paragraph.Title
		paragraph.Desc = desc or paragraph.Desc
		local frame = paragraph.ParagraphFrame
		local elements = frame and frame.UIElements
		if elements then
			if title and elements.Title then
				elements.Title.Text = title
				elements.Title.Visible = true
			end
			if desc and elements.Desc then
				elements.Desc.Text = desc
				elements.Desc.Visible = true
			end
		end
	end

	local function logLines(limit)
		limit = limit or 16
		local lines = {}
		for i = math.max(1, #Sentry.Logs - limit + 1), #Sentry.Logs do
			local entry = Sentry.Logs[i]
			table.insert(lines, ("[%s] %s  %s"):format(entry.Time, entry.Level, entry.Message))
		end
		return #lines > 0 and table.concat(lines, "\n") or "No logs yet."
	end

	local function robloxImageId(raw)
		local value = tostring(raw or ""):gsub("%D", "")
		if value == "" then
			return "0"
		end
		return value
	end

	function Sentry:Log(level, message)
		local entry = {
			Time = os.date("%H:%M:%S"),
			Level = tostring(level or "INFO"),
			Message = tostring(message or ""),
		}
		table.insert(self.Logs, entry)
		if #self.Logs > 120 then
			table.remove(self.Logs, 1)
		end
		print(("[Sentry:%s] %s %s"):format(entry.Level, entry.Time, entry.Message))
		return entry
	end

	function Sentry:SetMotionProfile(profile)
		local speed = self.Motion[profile or "Balanced"] or 1
		safe(function()
			WindUI:SetAnimationSpeed(speed)
		end)
		safe(function()
			WindUI:SetReducedMotion(profile == "Reduced")
		end)
		self:Log("MOTION", "Motion profile set to " .. tostring(profile or "Balanced"))
		return speed
	end

	function Sentry:UseTheme(name)
		self.Theme = tostring(name or "Aurora")
		local data = themeData()
		self.Accent = data.Accent
		safe(function()
			WindUI:UsePreset(self.Theme)
		end)
		safe(function()
			WindUI:SetTheme(self.Theme)
		end)
		self:Log("THEME", self.Theme .. " applied — " .. data.Label)
		return self.Theme
	end

	function Sentry:ThemeNames()
		return { "Aurora", "Obsidian", "Cyber", "Royal", "Velvet", "Glacier", "Solar", "Eclipse", "Crimson", "Emerald", "Dark", "Light" }
	end

	function Sentry:IntroBlocking(config)
		config = config or {}
		if not LocalPlayer then
			return
		end

		local playerGui = LocalPlayer:WaitForChild("PlayerGui")
		local gui = Instance.new("ScreenGui")
		gui.Name = "Sentry_Intro_Loading"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 999999
		gui.Parent = playerGui

		local background = Instance.new("Frame")
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = Color3.fromRGB(4, 7, 14)
		background.BackgroundTransparency = 1
		background.BorderSizePixel = 0
		background.Parent = gui

		local card = Instance.new("Frame")
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Position = UDim2.fromScale(0.5, 0.56)
		card.Size = UDim2.fromOffset(560, 285)
		card.BackgroundColor3 = Color3.fromRGB(15, 18, 30)
		card.BackgroundTransparency = 1
		card.BorderSizePixel = 0
		card.Parent = background

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 28)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.Accent
		stroke.Thickness = 1.8
		stroke.Transparency = 1
		stroke.Parent = card

		local glow = Instance.new("ImageLabel")
		glow.BackgroundTransparency = 1
		glow.Image = "rbxassetid://5028857472"
		glow.ImageColor3 = self.Accent
		glow.ImageTransparency = 1
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.Size = UDim2.new(1, 96, 1, 96)
		glow.ZIndex = 0
		glow.Parent = card

		local title = Instance.new("TextLabel")
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(34, 30)
		title.Size = UDim2.new(1, -68, 0, 42)
		title.Font = Enum.Font.GothamBlack
		title.Text = config.Title or self.Brand
		title.TextColor3 = Color3.fromRGB(250, 255, 250)
		title.TextTransparency = 1
		title.TextSize = 31
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = card

		local subtitle = Instance.new("TextLabel")
		subtitle.BackgroundTransparency = 1
		subtitle.Position = UDim2.fromOffset(36, 76)
		subtitle.Size = UDim2.new(1, -72, 0, 28)
		subtitle.Font = Enum.Font.GothamMedium
		subtitle.Text = config.Subtitle or "Preparing production interface assets..."
		subtitle.TextColor3 = Color3.fromRGB(198, 207, 225)
		subtitle.TextTransparency = 1
		subtitle.TextSize = 15
		subtitle.TextXAlignment = Enum.TextXAlignment.Left
		subtitle.Parent = card

		local console = Instance.new("TextLabel")
		console.BackgroundTransparency = 1
		console.Position = UDim2.fromOffset(36, 122)
		console.Size = UDim2.new(1, -72, 0, 88)
		console.Font = Enum.Font.Code
		console.Text = ""
		console.TextColor3 = self.Accent
		console.TextTransparency = 1
		console.TextSize = 14
		console.TextXAlignment = Enum.TextXAlignment.Left
		console.TextYAlignment = Enum.TextYAlignment.Top
		console.Parent = card

		local barBack = Instance.new("Frame")
		barBack.Position = UDim2.fromOffset(36, 232)
		barBack.Size = UDim2.new(1, -72, 0, 8)
		barBack.BackgroundColor3 = Color3.fromRGB(45, 52, 68)
		barBack.BackgroundTransparency = 1
		barBack.BorderSizePixel = 0
		barBack.Parent = card

		local backCorner = Instance.new("UICorner")
		backCorner.CornerRadius = UDim.new(1, 0)
		backCorner.Parent = barBack

		local bar = Instance.new("Frame")
		bar.Size = UDim2.fromScale(0, 1)
		bar.BackgroundColor3 = self.Accent
		bar.BorderSizePixel = 0
		bar.Parent = barBack

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		tween(background, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 })
		tween(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 0.03 })
		tween(stroke, TweenInfo.new(0.35), { Transparency = 0.1 })
		tween(glow, TweenInfo.new(0.45), { ImageTransparency = 0.7 })
		tween(title, TweenInfo.new(0.35), { TextTransparency = 0 })
		tween(subtitle, TweenInfo.new(0.35), { TextTransparency = 0.12 })
		tween(console, TweenInfo.new(0.35), { TextTransparency = 0.02 })
		tween(barBack, TweenInfo.new(0.35), { BackgroundTransparency = 0.15 })

		local steps = config.Steps or {
			"loading icon registry",
			"mounting sections and tab groups",
			"preparing player profile card",
			"syncing console log stream",
			"loading visual background tools",
			"checking friend system",
			"starting theme studio animation layer",
			"opening Sentry interface",
		}

		for i, step in ipairs(steps) do
			console.Text ..= "> " .. step .. "\n"
			self:Log("INTRO", step)
			tween(bar, TweenInfo.new(config.StepDelay or 0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromScale(i / #steps, 1) })
			task.wait(config.StepDelay or 0.48)
		end

		task.wait(config.Hold or 0.65)
		tween(card, TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.fromScale(0.5, 0.45), BackgroundTransparency = 1 })
		tween(background, TweenInfo.new(0.38), { BackgroundTransparency = 1 })
		tween(glow, TweenInfo.new(0.25), { ImageTransparency = 1 })
		tween(title, TweenInfo.new(0.25), { TextTransparency = 1 })
		tween(subtitle, TweenInfo.new(0.25), { TextTransparency = 1 })
		tween(console, TweenInfo.new(0.25), { TextTransparency = 1 })
		task.wait(0.45)
		gui:Destroy()
		self:Log("INTRO", "Intro completed and removed before UI opened")
	end

	function Sentry:CreateWindow(config)
		local window = safe(function()
			return WindUI:CreateWindow({
				Title = (config and config.Title) or self.Brand,
				Icon = self.Icons.Shield,
				Author = "Production Roblox UI Framework",
				Folder = "Sentry-Hub-Library",
				Theme = self.Theme,
				Size = (config and config.Size) or UDim2.fromOffset(650, 520),
				Acrylic = true,
				Premium = true,
				Glow = true,
				NewElements = true,
				HideSearchBar = false,
				ToggleKey = Enum.KeyCode.RightControl,
				OpenButton = { Title = "Open Sentry", Enabled = true, Draggable = true, OnlyMobile = false, Scale = 0.52 },
			})
		end)
		self.Window = window
		if window then
			safe(function()
				window:Tag({ Title = "Production " .. self.Version, Icon = self.Icons.Shield, Color = self.Accent, Border = true })
			end)
		end
		return window
	end

	function Sentry:ProfilePanel(tab)
		if not tab or not LocalPlayer then return end
		local avatar = "rbxthumb://type=Avatar&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
		safe(function() tab:Section({ Title = "Player Profile", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.Profile = tab:Paragraph({
				Title = LocalPlayer.DisplayName .. "  @" .. LocalPlayer.Name,
				Desc = "Account ID: " .. LocalPlayer.UserId .. "\nAccount Age: " .. LocalPlayer.AccountAge .. " days\nAvatar preview is contained inside the Sentry UI.",
				Thumbnail = avatar,
				ThumbnailSize = 145,
				Color = self.Accent,
			})
		end)
	end

	function Sentry:BuildMain(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Sentry Hub Library", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Paragraph({
				Title = "Production UI System Online",
				Desc = "Everything is now contained inside this UI: console logs, profile card, image background preview, friend stats, themes, sections, key system, and performance status.",
				Image = self.Icons.Home,
				Color = self.Accent,
				Buttons = {
					{ Title = "Highlight Test", Icon = self.Icons.Glow, Callback = function() self:Log("MAIN", "Highlight test pressed") notify("Success", "Highlight", "Glow/highlight feedback is contained inside Sentry.", 2) end },
				},
			})
		end)
		self:ProfilePanel(tab)
		safe(function() tab:Section({ Title = "Live Status", TextSize = 20, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.MainStatus = tab:Paragraph({
				Title = "Runtime State",
				Desc = "Theme: " .. self.Theme .. "\nLive Background: " .. tostring(self.State.LiveBackground) .. "\nImage Background ID: " .. tostring(self.State.ImageBackgroundId),
				Image = self.Icons.Performance,
				Color = self.Accent,
			})
		end)
	end

	function Sentry:BuildConsole(tab)
		if not tab then return end
		self:Log("CONSOLE", "Console tab mounted inside UI")
		safe(function() tab:Section({ Title = "Detailed Console Log", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.Console = tab:Paragraph({
				Title = "Runtime Log Stream",
				Desc = logLines(16),
				Image = self.Icons.Console,
				Color = self.Accent,
				Buttons = {
					{ Title = "Add Test Log", Icon = self.Icons.Console, Callback = function() self:Log("TEST", "Manual test log created from Console tab") paragraphSet(self.Refs.Console, "Runtime Log Stream", logLines(16)) end },
					{ Title = "Copy Logs", Icon = self.Icons.Copy, Callback = function() if setclipboard then setclipboard(logLines(40)) end notify("Info", "Console", "Copied latest logs if clipboard exists.", 2) end },
				},
			})
		end)
	end

	function Sentry:FriendSummary()
		local result = { Total = 0, Online = 0, Offline = 0, InServer = {}, Error = nil }
		if not LocalPlayer then result.Error = "No LocalPlayer" return result end
		local ok, pages = pcall(function() return Players:GetFriendsAsync(LocalPlayer.UserId) end)
		if not ok or not pages then result.Error = tostring(pages) return result end
		local friendIds = {}
		local guard = 0
		while true do
			guard += 1
			local page = safe(function() return pages:GetCurrentPage() end) or {}
			for _, friend in ipairs(page) do
				local id = tonumber(friend.Id or friend.UserId)
				result.Total += 1
				if friend.IsOnline then result.Online += 1 else result.Offline += 1 end
				if id then friendIds[id] = friend end
			end
			if pages.IsFinished or guard > 20 then break end
			local advanced = pcall(function() pages:AdvanceToNextPageAsync() end)
			if not advanced then break end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and friendIds[player.UserId] then
				table.insert(result.InServer, { UserId = player.UserId, Username = player.Name, DisplayName = player.DisplayName })
			end
		end
		return result
	end

	function Sentry:FriendText()
		local summary = self:FriendSummary()
		local inServer = "None detected"
		if #summary.InServer > 0 then
			local names = {}
			for _, friend in ipairs(summary.InServer) do table.insert(names, friend.DisplayName .. " (@" .. friend.Username .. ")") end
			inServer = table.concat(names, "\n")
		end
		if summary.Error then
			return "Friend data could not load: " .. summary.Error
		end
		return "Total Friends: " .. summary.Total .. "\nOnline: " .. summary.Online .. "\nOffline: " .. summary.Offline .. "\nFriends in Server: " .. #summary.InServer .. "\n\n" .. inServer
	end

	function Sentry:BuildFriends(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Friend System", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.Friends = tab:Paragraph({
				Title = "Live Roblox Friend Overview",
				Desc = self:FriendText(),
				Image = self.Icons.Friends,
				Color = self.Accent,
				Buttons = {
					{ Title = "Refresh Stats", Icon = self.Icons.Refresh, Callback = function() paragraphSet(self.Refs.Friends, "Live Roblox Friend Overview", self:FriendText()) self:Log("FRIENDS", "Manual friend refresh") end },
				},
			})
		end)
	end

	function Sentry:BuildElements(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Sections", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function() tab:Paragraph({ Title = "Section Layout", Desc = "Tabs are now separated with clear production sections for readability and polish.", Image = self.Icons.Elements, Color = self.Accent }) end)
		safe(function() tab:Section({ Title = "Interactive Controls", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function() tab:Button({ Title = "Highlighted Button", Desc = "Contained callback. No oversized transition or clutter window.", Icon = self.Icons.Glow, Color = self.Accent, Callback = function() self:Log("BUTTON", "Highlighted button pressed") notify("Success", "Highlight", "Glow/highlight feedback is contained inside Sentry.", 2) end }) end)
		safe(function() tab:Toggle({ Title = "Glow Toggle", Desc = "Demo state with clean feedback.", Value = true, Callback = function(v) self:Log("TOGGLE", "Glow Toggle = " .. tostring(v)) notify("Info", "Toggle", "Glow Toggle: " .. tostring(v), 2) end }) end)
		safe(function() tab:Slider({ Title = "Animation Speed", Desc = "Controls UI animation pacing.", IsTooltip = true, Step = 0.1, Value = { Min = 0.5, Max = 2, Default = 1 }, Callback = function(v) safe(function() WindUI:SetAnimationSpeed(v) end) self:Log("MOTION", "Animation speed set to " .. tostring(v)) end }) end)
		safe(function() tab:Dropdown({ Title = "Motion Profile", Values = { "Cinematic", "Balanced", "Snappy", "Reduced" }, Value = "Balanced", Callback = function(v) self:SetMotionProfile(v) end }) end)
		safe(function() tab:Keybind({ Title = "Main Quick Action", Value = Enum.KeyCode.G, Callback = function() notify("Success", "Keybind", "Quick action triggered.", 2) self:Log("KEYBIND", "Main quick action fired") end }) end)
		safe(function() tab:Colorpicker({ Title = "Highlight / Glow Accent", Default = self.Accent, Callback = function(c) self.Accent = c self:Log("STYLE", "Accent color updated") notify("Success", "Accent", "Highlight color updated.", 2) end }) end)
	end

	function Sentry:BuildVisuals(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Contained Live Background", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.VisualStatus = tab:Paragraph({
				Title = "Live Background State",
				Desc = "Live Background: " .. tostring(self.State.LiveBackground) .. "\nAnimated Theme Cycle: " .. tostring(self.State.ThemeCycle) .. "\nAll visual systems stay inside this UI.",
				Image = self.Icons.Visuals,
				Color = self.Accent,
				Buttons = {
					{ Title = "Enable Live Mode", Icon = self.Icons.Glow, Callback = function() self.State.LiveBackground = true self:Log("VISUAL", "Contained live mode enabled") paragraphSet(self.Refs.VisualStatus, "Live Background State", "Live Background: true\nAnimated Theme Cycle: " .. tostring(self.State.ThemeCycle) .. "\nAll visual systems stay inside this UI.") notify("Success", "Live Background", "Contained live mode enabled.", 2) end },
					{ Title = "Disable", Icon = "x", Callback = function() self.State.LiveBackground = false self.State.ThemeCycle = false self:Log("VISUAL", "Contained live mode disabled") paragraphSet(self.Refs.VisualStatus, "Live Background State", "Live Background: false\nAnimated Theme Cycle: false\nAll visual systems stay inside this UI.") notify("Info", "Live Background", "Disabled.", 2) end },
				},
			})
		end)
		safe(function() tab:Section({ Title = "Image Background", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Input({
				Title = "Roblox Decal/Image ID",
				Desc = "Paste a Roblox store decal/image id. The preview stays inside this tab.",
				Placeholder = "Example: 1234567890",
				Callback = function(value)
					self.State.ImageBackgroundId = robloxImageId(value)
					self:Log("IMAGE", "Image background id set to " .. self.State.ImageBackgroundId)
					paragraphSet(self.Refs.ImageStatus, "Image Background Preview", "Current ID: " .. self.State.ImageBackgroundId .. "\nReopen/reload the tab to see a fresh thumbnail preview if Roblox has cached the asset.")
					notify("Success", "Image Background", "Saved id: " .. self.State.ImageBackgroundId, 2)
				end,
			})
		end)
		safe(function()
			self.Refs.ImageStatus = tab:Paragraph({
				Title = "Image Background Preview",
				Desc = "Current ID: " .. tostring(self.State.ImageBackgroundId) .. "\nThis is a contained image preview, not a separate screen overlay.",
				Thumbnail = "rbxassetid://" .. tostring(self.State.ImageBackgroundId),
				ThumbnailSize = 145,
				Color = self.Accent,
			})
		end)
	end

	function Sentry:BuildThemes(tab, window)
		if not tab then return end
		safe(function() tab:Section({ Title = "Animated Theme Studio", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.ThemeStatus = tab:Paragraph({
				Title = "Current Theme",
				Desc = self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: " .. tostring(self.State.ThemeCycle),
				Image = self.Icons.Themes,
				Color = self.Accent,
				Buttons = {
					{ Title = "Start Cycle", Icon = self.Icons.Glow, Callback = function() self.State.ThemeCycle = true self.State.LiveBackground = true self:Log("THEME", "Animated theme cycle started") paragraphSet(self.Refs.ThemeStatus, "Current Theme", self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: true") end },
					{ Title = "Stop Cycle", Icon = "pause", Callback = function() self.State.ThemeCycle = false self:Log("THEME", "Animated theme cycle stopped") paragraphSet(self.Refs.ThemeStatus, "Current Theme", self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: false") end },
				},
			})
		end)
		safe(function() tab:Section({ Title = "Theme Presets", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Dropdown({ Title = "Active Theme", Values = self:ThemeNames(), Value = self.Theme, Callback = function(v) self:UseTheme(v) safe(function() window:SetTheme(v) end) paragraphSet(self.Refs.ThemeStatus, "Current Theme", self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: " .. tostring(self.State.ThemeCycle)) notify("Success", "Theme", "Applied " .. tostring(v), 2) end })
		end)
		for _, name in ipairs(self:ThemeNames()) do
			local data = self.Themes[name]
			if data then
				safe(function() tab:Button({ Title = "Apply " .. name, Desc = data.Label, Icon = self.Icons.Brush, Color = data.Accent, Callback = function() self:UseTheme(name) safe(function() window:SetTheme(name) end) paragraphSet(self.Refs.ThemeStatus, "Current Theme", self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: " .. tostring(self.State.ThemeCycle)) notify("Success", "Theme", name .. " applied.", 2) end }) end)
			end
		end
	end

	function Sentry:BuildKeySystem(tab)
		if not tab then return end
		local validKeys = { SENTRY = true, ["SENTRY-HUB"] = true, ["SENTRY-PRO"] = true }
		local attempts = 0
		safe(function() tab:Section({ Title = "Advanced Key System", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.KeyStatus = tab:Paragraph({
				Title = "Access Status",
				Desc = "Locked state demo. Demo keys: SENTRY, SENTRY-HUB, SENTRY-PRO\nAttempts: 0",
				Image = self.Icons.Key,
				Color = self.Accent,
			})
		end)
		safe(function()
			tab:Input({
				Title = "Enter Access Key",
				Desc = "Client-side demo only. Real validation should be server-side.",
				Placeholder = "SENTRY",
				Callback = function(value)
					attempts += 1
					local key = tostring(value or "")
					if validKeys[key] then
						paragraphSet(self.Refs.KeyStatus, "Access Status", "Access granted with key: " .. key .. "\nAttempts: " .. attempts)
						self:Log("KEY", "Access granted")
						notify("Success", "Access Granted", "Sentry unlocked.", 2)
					else
						paragraphSet(self.Refs.KeyStatus, "Access Status", "Invalid key.\nAttempts: " .. attempts .. "\nTry: SENTRY")
						self:Log("KEY", "Invalid key attempt " .. attempts)
						notify("Error", "Invalid Key", "Attempt " .. attempts, 2)
					end
				end,
			})
		end)
	end

	function Sentry:BuildSettings(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Live Performance", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.Performance = tab:Paragraph({
				Title = "Performance Monitor",
				Desc = "FPS: --\nMemory: -- MB\nLive updating inside this tab.",
				Image = self.Icons.Performance,
				Color = self.Accent,
			})
		end)
		safe(function() tab:Section({ Title = "Accessibility", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function() tab:Dropdown({ Title = "Motion Profile", Values = { "Cinematic", "Balanced", "Snappy", "Reduced" }, Value = "Balanced", Callback = function(v) self:SetMotionProfile(v) end }) end)
	end

	function Sentry:BuildAbout(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "About Sentry Hub Library", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Paragraph({
				Title = "Contained Production UI Framework",
				Desc = "Version: " .. self.Version .. "\nAll showcase systems are now contained inside the library tabs. The intro appears first, completes slowly, disappears, then the UI opens smoothly.",
				Image = self.Icons.Shield,
				Color = self.Accent,
			})
		end)
	end

	function Sentry:StartLiveLoops(window)
		local lastFpsTime = os.clock()
		local frames = 0
		local themeIndex = 1
		local names = self:ThemeNames()
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not self.Live then
				if connection then connection:Disconnect() end
				return
			end
			frames += 1
			local now = os.clock()
			if now - lastFpsTime >= 1 then
				local fps = math.floor(frames / (now - lastFpsTime) + 0.5)
				frames = 0
				lastFpsTime = now
				local memory = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
				paragraphSet(self.Refs.Performance, "Performance Monitor", "FPS: " .. fps .. "\nMemory: " .. memory .. " MB\nLive updating inside this tab.")
				paragraphSet(self.Refs.Console, "Runtime Log Stream", logLines(16))
				paragraphSet(self.Refs.MainStatus, "Runtime State", "Theme: " .. self.Theme .. "\nLive Background: " .. tostring(self.State.LiveBackground) .. "\nImage Background ID: " .. tostring(self.State.ImageBackgroundId))
			end
			if self.State.ThemeCycle and now - self.State.LastPerformanceRefresh >= 3.25 then
				self.State.LastPerformanceRefresh = now
				themeIndex += 1
				if themeIndex > #names then themeIndex = 1 end
				local name = names[themeIndex]
				if self.Themes[name] then
					self:UseTheme(name)
					safe(function() window:SetTheme(name) end)
					paragraphSet(self.Refs.ThemeStatus, "Current Theme", self.Theme .. " — " .. themeData().Label .. "\nAnimated Cycle: true")
				end
			end
			if now - self.State.LastFriendRefresh >= 12 then
				self.State.LastFriendRefresh = now
				paragraphSet(self.Refs.Friends, "Live Roblox Friend Overview", self:FriendText())
			end
		end)
		table.insert(self.Connections, connection)
	end

	function Sentry:BuildShowcase()
		self.Live = true
		self:SetMotionProfile("Balanced")
		self:UseTheme("Aurora")
		self:IntroBlocking({ StepDelay = 0.48, Hold = 0.65 })

		local window = self:CreateWindow()
		if not window then
			return nil
		end

		local main = safe(function() return window:Tab({ Title = "Main", Desc = "Profile + status", Icon = self.Icons.Home, Border = true }) end)
		local elements = safe(function() return window:Tab({ Title = "Elements", Desc = "Sections + controls", Icon = self.Icons.Elements, Border = true }) end)
		local visuals = safe(function() return window:Tab({ Title = "Visuals", Desc = "Backgrounds", Icon = self.Icons.Visuals, Border = true }) end)
		local themes = safe(function() return window:Tab({ Title = "Themes", Desc = "Animated studio", Icon = self.Icons.Themes, Border = true }) end)
		local consoleTab = safe(function() return window:Tab({ Title = "Console Log", Desc = "Live logs", Icon = self.Icons.Console, Border = true }) end)
		local friends = safe(function() return window:Tab({ Title = "Friends", Desc = "Live friend stats", Icon = self.Icons.Friends, Border = true }) end)
		local keySystem = safe(function() return window:Tab({ Title = "Key System", Desc = "Access demo", Icon = self.Icons.Key, Border = true }) end)
		local settings = safe(function() return window:Tab({ Title = "Settings", Desc = "Performance", Icon = self.Icons.Settings, Border = true }) end)
		local about = safe(function() return window:Tab({ Title = "About", Desc = "Info", Icon = "info", Border = true }) end)

		self:BuildMain(main)
		self:BuildElements(elements)
		self:BuildVisuals(visuals)
		self:BuildThemes(themes, window)
		self:BuildConsole(consoleTab)
		self:BuildFriends(friends)
		self:BuildKeySystem(keySystem)
		self:BuildSettings(settings)
		self:BuildAbout(about)
		self:StartLiveLoops(window)

		notify("Success", "Sentry Hub Library", "Contained production showcase loaded.", 3)
		self:Log("READY", "Contained showcase loaded")
		return window
	end

	function Sentry:Destroy()
		self.Live = false
		for _, connection in ipairs(self.Connections) do
			safe(function() connection:Disconnect() end)
		end
		table.clear(self.Connections)
	end

	WindUI.SentryHub = Sentry
	WindUI.SentryProduction = Sentry
	WindUI.GodTierPlus = Sentry

	WindUI.CreateSentryShowcase = function(_) return Sentry:BuildShowcase() end
	WindUI.CreateSentryWindow = function(_, config) return Sentry:CreateWindow(config) end
	WindUI.SetSentryMotionProfile = function(_, profile) return Sentry:SetMotionProfile(profile) end
	WindUI.GetSentryFriendSummary = function(_) return Sentry:FriendSummary() end
	WindUI.NotifyInfo = function(_, title, content, duration) return notify("Info", title, content, duration) end
	WindUI.NotifySuccess = function(_, title, content, duration) return notify("Success", title, content, duration) end
	WindUI.NotifyWarning = function(_, title, content, duration) return notify("Warning", title, content, duration) end
	WindUI.NotifyError = function(_, title, content, duration) return notify("Error", title, content, duration) end
	WindUI.CreateGodTierShowcase = WindUI.CreateSentryShowcase
	WindUI.CreateGodTierWindow = WindUI.CreateSentryWindow

	return Sentry
end
