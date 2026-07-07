--[[
	WindUI GodTier Plus
	Additive premium extension layer for WindUI.

	Usage:
	local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/dist/main.lua"))()
	local GodTierPlus = loadstring(game:HttpGet("https://raw.githubusercontent.com/theentrophyenchelon-svg/WindUi/main/dist/godtier_plus.lua"))()
	GodTierPlus(WindUI)
]]

return function(WindUI)
	if type(WindUI) ~= "table" then
		return nil
	end

	if WindUI.GodTierPlus and WindUI.GodTierPlus.__installed then
		return WindUI.GodTierPlus
	end

	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Stats = game:GetService("Stats")

	local Plus = {
		__installed = true,
		Version = "1.8.0-godtier-plus",
		Profile = "Balanced",
		Accent = Color3.fromHex("#30FF6A"),
		Theme = "Aurora",
		Windows = {},
	}

	local motionProfiles = {
		Cinematic = { speed = 0.75, reduced = false },
		Balanced = { speed = 1, reduced = false },
		Snappy = { speed = 1.35, reduced = false },
		Reduced = { speed = 0.65, reduced = true },
	}

	local function safeCall(callback, ...)
		if type(callback) ~= "function" then
			return nil
		end

		local ok, result = pcall(callback, ...)
		if ok then
			return result
		end

		warn("[WindUI GodTier Plus]", result)
		return nil
	end

	local function merge(base, override)
		local result = {}
		for key, value in pairs(base or {}) do
			result[key] = value
		end
		for key, value in pairs(override or {}) do
			result[key] = value
		end
		return result
	end

	local function notify(kind, title, content, duration)
		local colors = {
			Info = Color3.fromHex("#4D9EFF"),
			Success = Color3.fromHex("#30FF6A"),
			Warning = Color3.fromHex("#FFD166"),
			Error = Color3.fromHex("#FF4D6D"),
		}

		return safeCall(function()
			return WindUI:Notify({
				Title = title or kind or "WindUI",
				Content = content or "Notification",
				Desc = content or "Notification",
				Duration = duration or 3,
				Color = colors[kind or "Info"],
				Icon = kind == "Success" and "check" or kind == "Warning" and "triangle-alert" or kind == "Error" and "circle-x" or "sparkles",
			})
		end)
	end

	function Plus:SetMotionProfile(profileName)
		local profile = motionProfiles[profileName] or motionProfiles.Balanced
		self.Profile = profileName or "Balanced"

		safeCall(function()
			WindUI:SetAnimationSpeed(profile.speed)
		end)

		safeCall(function()
			WindUI:SetReducedMotion(profile.reduced)
		end)

		return profile
	end

	function Plus:SetAccent(color)
		if typeof(color) == "Color3" then
			self.Accent = color
		end
		return self.Accent
	end

	function Plus:UseTheme(themeName)
		self.Theme = tostring(themeName or self.Theme or "Aurora")

		safeCall(function()
			WindUI:UsePreset(self.Theme)
		end)

		safeCall(function()
			WindUI:SetTheme(self.Theme)
		end)

		return self.Theme
	end

	function Plus:CreateWindow(config)
		local defaults = {
			Title = "WindUI GodTier",
			Icon = "sparkles",
			Author = "Premium Roblox UI Library",
			Folder = "WindUI-GodTier",
			Theme = self.Theme or "Aurora",
			Size = UDim2.fromOffset(660, 540),
			Acrylic = true,
			Premium = true,
			Glow = true,
			NewElements = true,
			HideSearchBar = false,
			ToggleKey = Enum.KeyCode.RightControl,
			OpenButton = {
				Title = "Open WindUI",
				Enabled = true,
				Draggable = true,
				OnlyMobile = false,
				Scale = 0.55,
			},
		}

		local window = safeCall(function()
			return WindUI:CreateWindow(merge(defaults, config))
		end)

		if window then
			table.insert(self.Windows, window)

			safeCall(function()
				window:Tag({
					Title = "GodTier+ " .. self.Version,
					Icon = "sparkles",
					Color = self.Accent,
					Border = true,
				})
			end)
		end

		return window
	end

	function Plus:CreateLoadingOverlay(config)
		config = config or {}

		local player = Players.LocalPlayer
		if not player then
			return nil
		end

		local gui = Instance.new("ScreenGui")
		gui.Name = config.Name or "WindUI_GodTier_Loading"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = player:WaitForChild("PlayerGui")

		local background = Instance.new("Frame")
		background.Name = "Background"
		background.Size = UDim2.fromScale(1, 1)
		background.BackgroundColor3 = config.BackgroundColor or Color3.fromRGB(8, 10, 18)
		background.BackgroundTransparency = 1
		background.Parent = gui

		local card = Instance.new("Frame")
		card.Name = "Card"
		card.AnchorPoint = Vector2.new(0.5, 0.5)
		card.Position = UDim2.fromScale(0.5, 0.54)
		card.Size = UDim2.fromOffset(390, 150)
		card.BackgroundColor3 = config.CardColor or Color3.fromRGB(18, 20, 32)
		card.BackgroundTransparency = 1
		card.Parent = background

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 22)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = config.Accent or self.Accent
		stroke.Thickness = 1.6
		stroke.Transparency = 1
		stroke.Parent = card

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.BackgroundTransparency = 1
		title.Position = UDim2.fromOffset(24, 24)
		title.Size = UDim2.new(1, -48, 0, 36)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 24
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextTransparency = 1
		title.Text = config.Title or "WindUI GodTier"
		title.Parent = card

		local subtitle = Instance.new("TextLabel")
		subtitle.Name = "Subtitle"
		subtitle.BackgroundTransparency = 1
		subtitle.Position = UDim2.fromOffset(24, 62)
		subtitle.Size = UDim2.new(1, -48, 0, 24)
		subtitle.Font = Enum.Font.GothamMedium
		subtitle.TextSize = 14
		subtitle.TextXAlignment = Enum.TextXAlignment.Left
		subtitle.TextColor3 = Color3.fromRGB(190, 196, 212)
		subtitle.TextTransparency = 1
		subtitle.Text = config.Subtitle or "Loading premium interface layer..."
		subtitle.Parent = card

		local barBack = Instance.new("Frame")
		barBack.Name = "ProgressBack"
		barBack.Position = UDim2.fromOffset(24, 104)
		barBack.Size = UDim2.new(1, -48, 0, 8)
		barBack.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
		barBack.BackgroundTransparency = 1
		barBack.Parent = card

		local barBackCorner = Instance.new("UICorner")
		barBackCorner.CornerRadius = UDim.new(1, 0)
		barBackCorner.Parent = barBack

		local bar = Instance.new("Frame")
		bar.Name = "Progress"
		bar.Size = UDim2.fromScale(0, 1)
		bar.BackgroundColor3 = config.Accent or self.Accent
		bar.BackgroundTransparency = 0
		bar.Parent = barBack

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		TweenService:Create(background, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 }):Play()
		TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.08, Position = UDim2.fromScale(0.5, 0.5) }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0.2 }):Play()
		TweenService:Create(title, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
		TweenService:Create(subtitle, TweenInfo.new(0.25), { TextTransparency = 0.12 }):Play()
		TweenService:Create(barBack, TweenInfo.new(0.25), { BackgroundTransparency = 0.15 }):Play()
		TweenService:Create(bar, TweenInfo.new(config.Duration or 1.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()

		local controller = {}

		function controller:SetProgress(alpha)
			alpha = math.clamp(tonumber(alpha) or 0, 0, 1)
			TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromScale(alpha, 1) }):Play()
		end

		function controller:Destroy()
			TweenService:Create(background, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(card, TweenInfo.new(0.22), { BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.47) }):Play()
			TweenService:Create(title, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
			TweenService:Create(subtitle, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
			task.delay(0.3, function()
				if gui then
					gui:Destroy()
				end
			end)
		end

		if config.AutoDestroy ~= false then
			task.delay((config.Duration or 1.15) + 0.25, function()
				controller:Destroy()
			end)
		end

		return controller
	end

	function Plus:CreatePerformanceOverlay(config)
		config = config or {}

		local player = Players.LocalPlayer
		if not player then
			return nil
		end

		local gui = Instance.new("ScreenGui")
		gui.Name = config.Name or "WindUI_GodTier_Performance"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = player:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Name = "Panel"
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.Position = UDim2.new(1, -18, 0, 18)
		frame.Size = UDim2.fromOffset(180, 58)
		frame.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
		frame.BackgroundTransparency = 0.12
		frame.Parent = gui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = config.Accent or self.Accent
		stroke.Thickness = 1
		stroke.Transparency = 0.28
		stroke.Parent = frame

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(12, 8)
		label.Size = UDim2.new(1, -24, 1, -16)
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.TextColor3 = Color3.fromRGB(240, 245, 255)
		label.Text = "FPS: --\nMemory: -- MB"
		label.Parent = frame

		local last = os.clock()
		local frames = 0
		local connection

		connection = RunService.RenderStepped:Connect(function()
			frames += 1
			local now = os.clock()
			if now - last >= 0.5 then
				local fps = math.floor(frames / (now - last) + 0.5)
				frames = 0
				last = now

				local memory = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
				label.Text = "FPS: " .. fps .. "\nMemory: " .. memory .. " MB"
			end
		end)

		local controller = {}
		function controller:Destroy()
			if connection then
				connection:Disconnect()
			end
			gui:Destroy()
		end

		return controller
	end

	function Plus:BuildElementShowcase(tab)
		if not tab then
			return nil
		end

		safeCall(function()
			tab:Section({ Title = "GodTier Elements", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		safeCall(function()
			tab:Button({
				Title = "Premium Button",
				Desc = "Runs a premium feedback action.",
				Icon = "sparkles",
				Callback = function()
					notify("Success", "Premium Button", "Button feedback is online.")
				end,
			})
		end)

		safeCall(function()
			tab:Toggle({
				Title = "Animated Toggle",
				Desc = "Smooth state feedback.",
				Value = true,
				Callback = function(value)
					notify("Info", "Toggle", "State: " .. tostring(value), 2)
				end,
			})
		end)

		safeCall(function()
			tab:Slider({
				Title = "Motion Intensity",
				Desc = "Controls animation speed.",
				IsTooltip = true,
				Step = 0.1,
				Value = { Min = 0.5, Max = 2, Default = 1 },
				Callback = function(value)
					safeCall(function()
						WindUI:SetAnimationSpeed(value)
					end)
				end,
			})
		end)

		safeCall(function()
			tab:Dropdown({
				Title = "Visual Profile",
				Desc = "Choose a motion profile.",
				Values = { "Cinematic", "Balanced", "Snappy", "Reduced" },
				Value = "Balanced",
				Callback = function(profile)
					self:SetMotionProfile(profile)
					notify("Info", "Motion Profile", "Applied: " .. tostring(profile), 2)
				end,
			})
		end)

		safeCall(function()
			tab:Input({
				Title = "Command Input",
				Desc = "Type any text to test input rendering.",
				Placeholder = "Type here...",
				Callback = function(value)
					notify("Info", "Input", tostring(value), 2)
				end,
			})
		end)

		safeCall(function()
			tab:Colorpicker({
				Title = "Accent Color",
				Desc = "Updates GodTier Plus accent memory.",
				Default = self.Accent,
				Callback = function(color)
					self:SetAccent(color)
					notify("Success", "Accent Updated", "Accent color saved.", 2)
				end,
			})
		end)

		return tab
	end

	function Plus:BuildThemeStudio(tab, window)
		if not tab then
			return nil
		end

		local themes = { "Aurora", "Obsidian", "Cyber", "Royal", "Dark", "Light" }

		safeCall(function()
			tab:Section({ Title = "Theme Studio", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		safeCall(function()
			tab:Paragraph({
				Title = "Live Theme Switching",
				Desc = "Preview theme presets and motion profiles without rebuilding your UI.",
			})
		end)

		safeCall(function()
			tab:Dropdown({
				Title = "Active Theme",
				Desc = "Choose a premium theme preset.",
				Values = themes,
				Value = self.Theme,
				Callback = function(themeName)
					self:UseTheme(themeName)
					safeCall(function()
						window:SetTheme(themeName)
					end)
					notify("Success", "Theme Studio", "Applied " .. tostring(themeName), 2)
				end,
			})
		end)

		for _, themeName in ipairs(themes) do
			safeCall(function()
				tab:Button({
					Title = "Apply " .. themeName,
					Desc = "Switch to " .. themeName .. " instantly.",
					Icon = "paintbrush",
					Callback = function()
						self:UseTheme(themeName)
						safeCall(function()
							window:SetTheme(themeName)
						end)
						notify("Success", "Theme Applied", themeName, 2)
					end,
				})
			end)
		end

		return tab
	end

	function Plus:BuildSettings(tab)
		if not tab then
			return nil
		end

		safeCall(function()
			tab:Section({ Title = "Performance + Accessibility", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		safeCall(function()
			tab:Dropdown({
				Title = "Motion Profile",
				Values = { "Cinematic", "Balanced", "Snappy", "Reduced" },
				Value = self.Profile,
				Callback = function(profile)
					self:SetMotionProfile(profile)
				end,
			})
		end)

		safeCall(function()
			tab:Button({
				Title = "Show Performance Overlay",
				Desc = "Displays FPS and memory usage.",
				Icon = "activity",
				Callback = function()
					self:CreatePerformanceOverlay()
					notify("Info", "Performance", "Overlay enabled.", 2)
				end,
			})
		end)

		safeCall(function()
			tab:Button({
				Title = "Play Loading Overlay",
				Desc = "Shows a premium loading card animation.",
				Icon = "loader",
				Callback = function()
					self:CreateLoadingOverlay({ Duration = 1.2 })
				end,
			})
		end)

		return tab
	end

	function Plus:BuildAbout(tab)
		if not tab then
			return nil
		end

		safeCall(function()
			tab:Section({ Title = "About GodTier Plus", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold })
		end)

		safeCall(function()
			tab:Paragraph({
				Title = "Elite Extension Layer",
				Desc = "GodTier Plus adds safer defaults, motion profiles, theme studio helpers, loading overlays, performance stats, premium notification helpers, and reusable showcase builders.",
			})
		end)

		safeCall(function()
			tab:Paragraph({
				Title = "Version",
				Desc = self.Version,
			})
		end)

		return tab
	end

	function Plus:BuildShowcase()
		self:SetMotionProfile("Balanced")
		self:UseTheme("Aurora")
		self:CreateLoadingOverlay({ Duration = 0.9 })

		local window = self:CreateWindow()
		if not window then
			return nil
		end

		local main = safeCall(function()
			return window:Tab({ Title = "Main", Desc = "Overview", Icon = "home", Border = true })
		end)
		local elements = safeCall(function()
			return window:Tab({ Title = "Elements", Desc = "Component showcase", Icon = "boxes", Border = true })
		end)
		local themes = safeCall(function()
			return window:Tab({ Title = "Themes", Desc = "Theme studio", Icon = "palette", Border = true })
		end)
		local settings = safeCall(function()
			return window:Tab({ Title = "Settings", Desc = "Performance", Icon = "settings", Border = true })
		end)
		local about = safeCall(function()
			return window:Tab({ Title = "About", Desc = "Info", Icon = "info", Border = true })
		end)

		if main then
			safeCall(function()
				main:Section({ Title = "WindUI GodTier Plus", TextSize = 24, FontWeight = Enum.FontWeight.SemiBold })
			end)
			safeCall(function()
				main:Paragraph({
					Title = "Premium UI system online",
					Desc = "A stronger WindUI layer with better defaults, reusable builders, theme tools, motion controls, loading overlays, and performance feedback.",
				})
			end)
			safeCall(function()
				main:Button({
					Title = "Test Premium Notification",
					Desc = "Runs the upgraded notification helper.",
					Icon = "bell",
					Callback = function()
						notify("Success", "GodTier Plus", "The upgraded showcase is running.")
					end,
				})
			end)
		end

		self:BuildElementShowcase(elements)
		self:BuildThemeStudio(themes, window)
		self:BuildSettings(settings)
		self:BuildAbout(about)

		notify("Success", "WindUI GodTier Plus", "Showcase loaded with premium systems.")
		return window
	end

	WindUI.GodTierPlus = Plus

	WindUI.NotifyInfo = function(_, title, content, duration)
		return notify("Info", title, content, duration)
	end

	WindUI.NotifySuccess = function(_, title, content, duration)
		return notify("Success", title, content, duration)
	end

	WindUI.NotifyWarning = function(_, title, content, duration)
		return notify("Warning", title, content, duration)
	end

	WindUI.NotifyError = function(_, title, content, duration)
		return notify("Error", title, content, duration)
	end

	WindUI.SetGodTierMotionProfile = function(_, profileName)
		return Plus:SetMotionProfile(profileName)
	end

	WindUI.CreateGodTierWindow = function(_, config)
		return Plus:CreateWindow(config)
	end

	WindUI.CreateGodTierLoadingOverlay = function(_, config)
		return Plus:CreateLoadingOverlay(config)
	end

	WindUI.CreateGodTierPerformanceOverlay = function(_, config)
		return Plus:CreatePerformanceOverlay(config)
	end

	WindUI.CreateGodTierShowcase = function(_)
		return Plus:BuildShowcase()
	end

	return Plus
end
