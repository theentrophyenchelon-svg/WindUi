--[[
	Sentry Hub Library Production Layer
	Production-grade additive systems for Sentry/WindUI runtime.
]]

return function(WindUI)
	if type(WindUI) ~= "table" then return nil end
	if WindUI.SentryProduction and WindUI.SentryProduction.__installed then return WindUI.SentryProduction end

	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Stats = game:GetService("Stats")
	local Lighting = game:GetService("Lighting")
	local LocalPlayer = Players.LocalPlayer

	local Sentry = {
		__installed = true,
		Brand = "Sentry Hub Library",
		Version = "2.0.0-production",
		Accent = Color3.fromHex("#30FF6A"),
		Theme = "Aurora",
		Connections = {},
		Guis = {},
		Logs = {},
		Icons = {
			Shield = "shield-check", Home = "home", Elements = "boxes", Visuals = "sparkles", Themes = "palette",
			Settings = "settings", Friends = "users", Key = "key-round", Console = "terminal", Profile = "circle-user-round",
			Performance = "activity", Image = "image", Brush = "paintbrush", Bell = "bell", Lock = "lock-keyhole",
		},
		Themes = {
			Aurora = { Accent = Color3.fromHex("#30FF6A"), Alt = Color3.fromHex("#7C5CFF"), Bg = Color3.fromHex("#071019"), Surface = Color3.fromHex("#111827"), Text = Color3.fromHex("#F8FAFC") },
			Obsidian = { Accent = Color3.fromHex("#9CA3AF"), Alt = Color3.fromHex("#60A5FA"), Bg = Color3.fromHex("#050505"), Surface = Color3.fromHex("#111111"), Text = Color3.fromHex("#F5F5F5") },
			Cyber = { Accent = Color3.fromHex("#00E5FF"), Alt = Color3.fromHex("#FF2BD6"), Bg = Color3.fromHex("#060014"), Surface = Color3.fromHex("#101024"), Text = Color3.fromHex("#F0FDFF") },
			Royal = { Accent = Color3.fromHex("#C084FC"), Alt = Color3.fromHex("#FACC15"), Bg = Color3.fromHex("#12091F"), Surface = Color3.fromHex("#221036"), Text = Color3.fromHex("#FDF4FF") },
			Velvet = { Accent = Color3.fromHex("#FF4D8D"), Alt = Color3.fromHex("#7C3AED"), Bg = Color3.fromHex("#170914"), Surface = Color3.fromHex("#28111F"), Text = Color3.fromHex("#FFF1F7") },
			Glacier = { Accent = Color3.fromHex("#7DD3FC"), Alt = Color3.fromHex("#A7F3D0"), Bg = Color3.fromHex("#07131A"), Surface = Color3.fromHex("#10202A"), Text = Color3.fromHex("#E0F2FE") },
			Solar = { Accent = Color3.fromHex("#F97316"), Alt = Color3.fromHex("#FDE047"), Bg = Color3.fromHex("#191007"), Surface = Color3.fromHex("#2A1908"), Text = Color3.fromHex("#FFF7ED") },
			Eclipse = { Accent = Color3.fromHex("#818CF8"), Alt = Color3.fromHex("#F472B6"), Bg = Color3.fromHex("#030712"), Surface = Color3.fromHex("#111827"), Text = Color3.fromHex("#EEF2FF") },
		},
		Motion = { Cinematic = .75, Balanced = 1, Snappy = 1.35, Reduced = .65 },
	}

	local function pcallr(fn, ...) local ok, res = pcall(fn, ...); if ok then return res end; warn("[Sentry]", res); return nil end
	local function c(class, props) local o = Instance.new(class); for k,v in pairs(props or {}) do o[k] = v end; return o end
	local function tw(o, time, props, style, dir) local t = TweenService:Create(o, TweenInfo.new(time or .25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props); t:Play(); return t end
	local function gui(name, order) if not LocalPlayer then return nil end; local g = c("ScreenGui", {Name=name, ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=order or 1000, Parent=LocalPlayer:WaitForChild("PlayerGui")}); table.insert(Sentry.Guis, g); return g end
	local function round(o, r) local x=c("UICorner",{CornerRadius=UDim.new(0,r or 16),Parent=o}); return x end
	local function stroke(o, col, tr) return c("UIStroke",{Color=col or Sentry.Accent,Transparency=tr or .25,Thickness=1.2,Parent=o}) end
	local function theme() return Sentry.Themes[Sentry.Theme] or Sentry.Themes.Aurora end

	function Sentry:Log(level, message)
		local line = {Time=os.date("%H:%M:%S"), Level=tostring(level or "INFO"), Message=tostring(message or "")}
		table.insert(self.Logs, line); if #self.Logs > 150 then table.remove(self.Logs,1) end
		print(("[Sentry:%s] %s %s"):format(line.Level,line.Time,line.Message)); return line
	end

	function Sentry:Notify(kind, title, text, duration)
		local map = {Info=Color3.fromHex("#4D9EFF"), Success=Color3.fromHex("#30FF6A"), Warning=Color3.fromHex("#FFD166"), Error=Color3.fromHex("#FF4D6D")}
		return pcallr(function() return WindUI:Notify({Title=title or self.Brand, Content=text or "", Desc=text or "", Duration=duration or 3, Color=map[kind] or self.Accent, Icon=self.Icons.Shield}) end)
	end

	function Sentry:SetMotionProfile(name)
		local speed = self.Motion[name or "Balanced"] or 1
		pcallr(function() WindUI:SetAnimationSpeed(speed) end)
		pcallr(function() WindUI:SetReducedMotion(name == "Reduced") end)
		self:Log("MOTION", "Profile set to "..tostring(name or "Balanced")); return speed
	end

	function Sentry:UseTheme(name)
		self.Theme = tostring(name or "Aurora"); local t = theme(); self.Accent = t.Accent
		pcallr(function() WindUI:UsePreset(self.Theme) end); pcallr(function() WindUI:SetTheme(self.Theme) end)
		self:Log("THEME", "Theme set to "..self.Theme); return self.Theme
	end

	function Sentry:ThemeNames()
		local names = {"Aurora","Cyber","Eclipse","Glacier","Obsidian","Royal","Solar","Velvet","Dark","Light"}; return names
	end

	function Sentry:Transition(config)
		config = config or {}; local g = gui("Sentry_Transition", 999999); if not g then return nil end
		local f = c("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=config.Color or Color3.fromRGB(3,6,12), BackgroundTransparency=1, BorderSizePixel=0, Parent=g})
		local blur = config.Blur ~= false and c("BlurEffect",{Name="SentryBlur",Size=0,Parent=Lighting}) or nil
		local ctrl = {}
		function ctrl:In(time) tw(f,time or .22,{BackgroundTransparency=config.Transparency or .08}); if blur then tw(blur,time or .22,{Size=config.BlurSize or 14}) end end
		function ctrl:Out(time) tw(f,time or .22,{BackgroundTransparency=1}); if blur then tw(blur,time or .22,{Size=0}) end; task.delay((time or .22)+.05,function() if blur then blur:Destroy() end; if g then g:Destroy() end end) end
		function ctrl:Pulse() self:In(.15); task.delay(.13,function() self:Out(.22) end) end
		return ctrl
	end

	function Sentry:LiveBackground(config)
		config = config or {}; local t=theme(); local g=gui("Sentry_LiveBackground", -100); if not g then return nil end
		local root=c("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=t.Bg,BorderSizePixel=0,Parent=g})
		local grad=c("UIGradient",{Color=ColorSequence.new(t.Bg,t.Alt),Rotation=0,Parent=root})
		local parts={}; for i=1,(config.Particles or 20) do local s=math.random(18,70); local p=c("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(s,s),BackgroundColor3=i%2==0 and t.Accent or t.Alt,BackgroundTransparency=math.random(68,88)/100,BorderSizePixel=0,Parent=root}); round(p,999); parts[i]={p=p,dx=math.random(4,13)/10000,dy=math.random(4,13)/10000,o=math.random()*6.28} end
		local alive=true; local con=RunService.RenderStepped:Connect(function() if not alive then return end; local now=os.clock(); grad.Rotation=(now*10)%360; for _,x in ipairs(parts) do local pos=x.p.Position; local nx=pos.X.Scale+math.cos(now+x.o)*x.dx; local ny=pos.Y.Scale+math.sin(now+x.o)*x.dy; if nx>1.08 then nx=-.08 elseif nx<-.08 then nx=1.08 end; if ny>1.08 then ny=-.08 elseif ny<-.08 then ny=1.08 end; x.p.Position=UDim2.fromScale(nx,ny) end end)
		table.insert(self.Connections,con); return {Destroy=function() alive=false; con:Disconnect(); g:Destroy() end}
	end

	function Sentry:ImageBackground(config)
		config=config or {}; local g=gui("Sentry_ImageBackground", -90); if not g then return nil end
		c("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image=config.Image or "rbxassetid://0",ImageTransparency=config.Transparency or .35,ScaleType=Enum.ScaleType.Crop,Parent=g})
		c("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=config.Overlay or Color3.fromRGB(3,6,12),BackgroundTransparency=config.OverlayTransparency or .22,BorderSizePixel=0,Parent=g})
		return {Destroy=function() g:Destroy() end}
	end

	function Sentry:Intro(config)
		config=config or {}; local t=theme(); local tr=self:Transition({BlurSize=18}); if tr then tr:In(.2) end; local g=gui("Sentry_Intro",999998); if not g then return nil end
		local card=c("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.56),Size=UDim2.fromOffset(530,255),BackgroundColor3=t.Surface,BackgroundTransparency=1,BorderSizePixel=0,Parent=g}); round(card,26); stroke(card,t.Accent,.22); c("UIGradient",{Color=ColorSequence.new(t.Surface,t.Alt),Rotation=25,Parent=card})
		local title=c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(30,30),Size=UDim2.new(1,-60,0,42),Font=Enum.Font.GothamBlack,Text=config.Title or self.Brand,TextColor3=t.Text,TextTransparency=1,TextSize=31,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		local sub=c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(32,76),Size=UDim2.new(1,-64,0,28),Font=Enum.Font.GothamMedium,Text=config.Subtitle or "Production interface systems initializing...",TextColor3=Color3.fromRGB(195,205,222),TextTransparency=1,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		local log=c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(32,122),Size=UDim2.new(1,-64,0,58),Font=Enum.Font.Code,Text="",TextColor3=t.Accent,TextTransparency=1,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=card})
		local back=c("Frame",{Position=UDim2.fromOffset(32,199),Size=UDim2.new(1,-64,0,8),BackgroundColor3=Color3.fromRGB(50,56,70),BackgroundTransparency=1,BorderSizePixel=0,Parent=card}); round(back,999)
		local bar=c("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=t.Accent,BorderSizePixel=0,Parent=back}); round(bar,999)
		tw(card,.42,{Position=UDim2.fromScale(.5,.5),BackgroundTransparency=.04},Enum.EasingStyle.Back); tw(title,.25,{TextTransparency=0}); tw(sub,.25,{TextTransparency=.12}); tw(log,.25,{TextTransparency=.04}); tw(back,.25,{BackgroundTransparency=.16})
		local steps=config.Steps or {"loading sentry runtime","mounting transitions","preparing avatar viewport","syncing theme studio","starting production interface"}
		task.spawn(function() for i,s in ipairs(steps) do log.Text=log.Text.."> "..s.."\n"; tw(bar,.22,{Size=UDim2.fromScale(i/#steps,1)}); task.wait(config.StepDelay or .17) end; task.wait(config.Hold or .18); tw(card,.25,{Position=UDim2.fromScale(.5,.46),BackgroundTransparency=1}); tw(title,.18,{TextTransparency=1}); tw(sub,.18,{TextTransparency=1}); tw(log,.18,{TextTransparency=1}); task.delay(.3,function() if tr then tr:Out(.2) end; if g then g:Destroy() end end) end)
		return g
	end

	function Sentry:Console(config)
		config=config or {}; local t=theme(); local g=gui("Sentry_Console",99990); if not g then return nil end
		local f=c("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.fromOffset(config.Width or 440,config.Height or 235),BackgroundColor3=t.Bg,BackgroundTransparency=.04,BorderSizePixel=0,Parent=g}); round(f,18); stroke(f,t.Accent,.22)
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(16,12),Size=UDim2.new(1,-32,0,24),Text="Sentry Console",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=t.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
		local body=c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(16,44),Size=UDim2.new(1,-32,1,-58),Text="",Font=Enum.Font.Code,TextSize=13,TextColor3=Color3.fromRGB(210,255,225),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Parent=f})
		local ctrl={}; function ctrl:Render() local lines={}; for i=math.max(1,#Sentry.Logs-10),#Sentry.Logs do local e=Sentry.Logs[i]; table.insert(lines,("[%s] %s %s"):format(e.Time,e.Level,e.Message)) end; body.Text=table.concat(lines,"\n") end; function ctrl:Log(l,m) Sentry:Log(l,m); self:Render() end; function ctrl:Destroy() g:Destroy() end; ctrl:Log("BOOT","Console attached"); return ctrl
	end

	function Sentry:AvatarViewportCard(parent, config)
		config=config or {}; local p=LocalPlayer; if not p then return nil end
		if parent and type(parent.Section)=="function" then pcallr(function() parent:Section({Title="Player Profile",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() parent:Paragraph({Title=p.DisplayName.."  @"..p.Name,Desc="Account ID: "..p.UserId.."\nAccount Age: "..p.AccountAge.." days\nViewport avatar available from Visuals tab."}) end); return end
		local t=theme(); local g=gui("Sentry_AvatarViewport",99982); if not g then return nil end
		local card=c("Frame",{AnchorPoint=Vector2.new(.5,0),Position=config.Position or UDim2.new(.5,0,0,18),Size=UDim2.fromOffset(440,165),BackgroundColor3=t.Surface,BackgroundTransparency=.05,BorderSizePixel=0,Parent=g}); round(card,20); stroke(card,t.Accent,.25)
		local vp=c("ViewportFrame",{Position=UDim2.fromOffset(18,18),Size=UDim2.fromOffset(124,124),BackgroundColor3=t.Bg,BackgroundTransparency=.1,Ambient=Color3.fromRGB(180,190,210),LightColor=Color3.new(1,1,1),LightDirection=Vector3.new(-1,-2,-1),Parent=card}); round(vp,18); local cam=Instance.new("Camera"); cam.FieldOfView=38; cam.Parent=vp; vp.CurrentCamera=cam
		task.spawn(function() local model=pcallr(function() return Players:CreateHumanoidModelFromUserId(p.UserId) end); if model then model.Parent=vp; model:PivotTo(CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(180),0)); cam.CFrame=CFrame.new(Vector3.new(0,2.2,6),Vector3.new(0,2.2,0)) end end)
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(158,28),Size=UDim2.new(1,-178,0,28),Font=Enum.Font.GothamBold,Text=p.DisplayName,TextSize=22,TextColor3=t.Text,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(158,58),Size=UDim2.new(1,-178,0,22),Font=Enum.Font.GothamMedium,Text="@"..p.Name,TextSize=15,TextColor3=t.Accent,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(158,92),Size=UDim2.new(1,-178,0,48),Font=Enum.Font.Gotham,Text="Account ID: "..p.UserId.."\nAccount Age: "..p.AccountAge.." days",TextSize=14,TextColor3=Color3.fromRGB(198,206,220),TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=card})
		return {Destroy=function() g:Destroy() end}
	end

	function Sentry:FriendSummary()
		local out={Total=0,Online=0,Offline=0,InServer={},Error=nil}; local p=LocalPlayer; if not p then out.Error="No LocalPlayer"; return out end
		local ok,pages=pcall(function() return Players:GetFriendsAsync(p.UserId) end); if not ok or not pages then out.Error=tostring(pages); return out end
		local byId={}; local guard=0; while true do guard+=1; local page=pcallr(function() return pages:GetCurrentPage() end) or {}; for _,fr in ipairs(page) do local id=tonumber(fr.Id or fr.UserId); out.Total+=1; if fr.IsOnline then out.Online+=1 else out.Offline+=1 end; if id then byId[id]=fr end end; if pages.IsFinished or guard>20 then break end; if not pcall(function() pages:AdvanceToNextPageAsync() end) then break end end
		for _,plr in ipairs(Players:GetPlayers()) do if plr~=p and byId[plr.UserId] then table.insert(out.InServer,{UserId=plr.UserId,Username=plr.Name,DisplayName=plr.DisplayName}) end end; return out
	end

	function Sentry:AdvancedKeySystem(config)
		config=config or {}; local p=LocalPlayer; if not p then return nil end; local t=theme(); local keys={}; for _,k in ipairs(config.Keys or {"SENTRY","SENTRY-HUB","SENTRY-PRO"}) do keys[tostring(k)]=true end; local attempts=0; local max=config.MaxAttempts or 5
		local g=gui("Sentry_KeySystem",999997); local bg=c("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=t.Bg,BackgroundTransparency=.08,BorderSizePixel=0,Parent=g}); local card=c("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(445,255),BackgroundColor3=t.Surface,BackgroundTransparency=.03,BorderSizePixel=0,Parent=bg}); round(card,24); stroke(card,t.Accent,.2)
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(28,28),Size=UDim2.new(1,-56,0,34),Font=Enum.Font.GothamBlack,Text=config.Title or "Sentry Access",TextColor3=t.Text,TextSize=26,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(30,66),Size=UDim2.new(1,-60,0,44),Font=Enum.Font.GothamMedium,Text=config.Subtitle or "Enter your access key to unlock the interface.",TextColor3=Color3.fromRGB(190,200,220),TextSize=14,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})
		local input=c("TextBox",{Position=UDim2.fromOffset(30,124),Size=UDim2.new(1,-60,0,42),BackgroundColor3=t.Bg,BackgroundTransparency=.08,Font=Enum.Font.GothamMedium,PlaceholderText="Enter key...",Text="",TextColor3=t.Text,TextSize=15,ClearTextOnFocus=false,Parent=card}); round(input,14); stroke(input,Color3.fromRGB(80,90,110),.45)
		local btn=c("TextButton",{Position=UDim2.fromOffset(30,184),Size=UDim2.new(1,-60,0,42),BackgroundColor3=t.Accent,Font=Enum.Font.GothamBold,Text="Unlock Sentry",TextColor3=Color3.fromRGB(5,8,12),TextSize=15,Parent=card}); round(btn,14)
		local ctrl={Unlocked=false}; local function check() attempts+=1; local val=input.Text; local allowed=type(config.Validator)=="function" and pcallr(config.Validator,val,attempts)==true or keys[val]==true; if allowed then ctrl.Unlocked=true; Sentry:Notify("Success","Access Granted","Sentry Hub Library unlocked.",2); tw(bg,.25,{BackgroundTransparency=1}); tw(card,.25,{BackgroundTransparency=1,Position=UDim2.fromScale(.5,.46)}); task.delay(.28,function() g:Destroy(); if type(config.OnSuccess)=="function" then pcallr(config.OnSuccess,val) end end) else Sentry:Notify("Error","Invalid Key","Attempt "..attempts.." of "..max,2); tw(card,.06,{Position=UDim2.fromScale(.492,.5)}); task.delay(.06,function() tw(card,.06,{Position=UDim2.fromScale(.508,.5)}); task.delay(.06,function() tw(card,.06,{Position=UDim2.fromScale(.5,.5)}) end) end); if attempts>=max and type(config.OnLocked)=="function" then pcallr(config.OnLocked) end end end
		btn.MouseButton1Click:Connect(check); input.FocusLost:Connect(function(enter) if enter then check() end end); return ctrl
	end

	function Sentry:CreateWindow(config)
		local win=pcallr(function() return WindUI:CreateWindow({Title=(config and config.Title) or self.Brand,Icon=self.Icons.Shield,Author="Production Roblox UI Framework",Folder="Sentry-Hub-Library",Theme=self.Theme,Size=(config and config.Size) or UDim2.fromOffset(700,560),Acrylic=true,Premium=true,Glow=true,NewElements=true,HideSearchBar=false,ToggleKey=Enum.KeyCode.RightControl,OpenButton={Title="Open Sentry",Enabled=true,Draggable=true,OnlyMobile=false,Scale=.55}}) end)
		if win then pcallr(function() win:Tag({Title="Production "..self.Version,Icon=self.Icons.Shield,Color=self.Accent,Border=true}) end) end; return win
	end

	function Sentry:BuildElements(tab) if not tab then return end; pcallr(function() tab:Section({Title="Production Elements",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() tab:Button({Title="Premium Button",Desc="Runs refined feedback with transition polish.",Icon=self.Icons.Shield,Callback=function() local tr=self:Transition(); if tr then tr:Pulse() end; self:Notify("Success","Premium Button","Production feedback is online.") end}) end); pcallr(function() tab:Toggle({Title="Animated Toggle",Desc="Smooth state feedback.",Value=true,Callback=function(v) self:Notify("Info","Toggle","State: "..tostring(v),2) end}) end); pcallr(function() tab:Slider({Title="Motion Intensity",Desc="Controls animation speed.",IsTooltip=true,Step=.1,Value={Min=.5,Max=2,Default=1},Callback=function(v) pcallr(function() WindUI:SetAnimationSpeed(v) end) end}) end); pcallr(function() tab:Dropdown({Title="Visual Profile",Values={"Cinematic","Balanced","Snappy","Reduced"},Value="Balanced",Callback=function(v) self:SetMotionProfile(v) end}) end); pcallr(function() tab:Input({Title="Command Input",Placeholder="Type here...",Callback=function(v) self:Notify("Info","Input",tostring(v),2) end}) end); pcallr(function() tab:Keybind({Title="Sentry Quick Action",Value=Enum.KeyCode.G,Callback=function() self:Notify("Success","Keybind","Quick action triggered.",2) end}) end); pcallr(function() tab:Colorpicker({Title="Accent Color",Default=self.Accent,Callback=function(v) self.Accent=v; self:Notify("Success","Accent Updated","Accent color saved.",2) end}) end) end

	function Sentry:BuildThemes(tab, window) if not tab then return end; pcallr(function() tab:Section({Title="Theme Studio",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() tab:Paragraph({Title="Gradient + Animated Themes",Desc="Aurora, Cyber, Eclipse, Glacier, Obsidian, Royal, Solar, Velvet, Dark, and Light compatible presets."}) end); pcallr(function() tab:Dropdown({Title="Active Theme",Values=self:ThemeNames(),Value=self.Theme,Callback=function(v) self:UseTheme(v); pcallr(function() window:SetTheme(v) end); self:Notify("Success","Theme Studio","Applied "..tostring(v),2) end}) end); for _,name in ipairs(self:ThemeNames()) do pcallr(function() tab:Button({Title="Apply "..name,Icon=self.Icons.Brush,Callback=function() self:UseTheme(name); pcallr(function() window:SetTheme(name) end) end}) end) end end

	function Sentry:BuildVisuals(tab) if not tab then return end; pcallr(function() tab:Section({Title="Visual Systems",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() tab:Button({Title="Play Advanced Intro",Icon=self.Icons.Visuals,Callback=function() self:Intro() end}) end); pcallr(function() tab:Button({Title="Enable Live Background",Icon=self.Icons.Visuals,Callback=function() self:LiveBackground(); self:Notify("Success","Live Background","Animated background enabled.",2) end}) end); pcallr(function() tab:Button({Title="Create Image Background",Icon=self.Icons.Image,Callback=function() self:ImageBackground({Image="rbxassetid://0"}); self:Notify("Info","Image Background","Replace asset id with production art.",3) end}) end); pcallr(function() tab:Button({Title="Open Console Log",Icon=self.Icons.Console,Callback=function() local x=self:Console(); if x then x:Log("READY","Production console online") end end}) end); pcallr(function() tab:Button({Title="Show Avatar Viewport",Icon=self.Icons.Profile,Callback=function() self:AvatarViewportCard(nil) end}) end) end

	function Sentry:BuildFriends(tab) if not tab then return end; pcallr(function() tab:Section({Title="Friend System",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); local s=self:FriendSummary(); local list="None detected"; if #s.InServer>0 then local names={}; for _,f in ipairs(s.InServer) do table.insert(names,f.DisplayName.." (@"..f.Username..")") end; list=table.concat(names,"\n") end; local text=s.Error and ("Friend data could not load: "..s.Error) or ("Total Friends: "..s.Total.."\nOnline: "..s.Online.."\nOffline: "..s.Offline.."\nFriends in server: "..#s.InServer.."\n\n"..list); pcallr(function() tab:Paragraph({Title="Roblox Friend Overview",Desc=text}) end); pcallr(function() tab:Button({Title="Refresh Friend Stats",Icon=self.Icons.Friends,Callback=function() local r=self:FriendSummary(); self:Notify("Info","Friends","Total: "..r.Total.." | In server: "..#r.InServer,3) end}) end) end

	function Sentry:BuildSecurity(tab) if not tab then return end; pcallr(function() tab:Section({Title="Advanced Key System",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() tab:Paragraph({Title="Production Access Layer",Desc="Client keys are UX gating only. Put real access validation on the server."}) end); pcallr(function() tab:Button({Title="Open Key System",Desc="Demo key: SENTRY",Icon=self.Icons.Key,Callback=function() self:AdvancedKeySystem({Keys={"SENTRY","SENTRY-HUB","SENTRY-PRO"}}) end}) end) end

	function Sentry:BuildSettings(tab) if not tab then return end; pcallr(function() tab:Section({Title="Performance + Accessibility",TextSize=22,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() tab:Dropdown({Title="Motion Profile",Values={"Cinematic","Balanced","Snappy","Reduced"},Value="Balanced",Callback=function(v) self:SetMotionProfile(v) end}) end); pcallr(function() tab:Button({Title="Show Performance Overlay",Icon=self.Icons.Performance,Callback=function() local overlay=gui("Sentry_Performance",99980); local t=theme(); local f=c("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,18),Size=UDim2.fromOffset(190,76),BackgroundColor3=t.Surface,BackgroundTransparency=.08,Parent=overlay}); round(f,15); stroke(f,t.Accent,.28); local label=c("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,1,-16),Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextColor3=t.Text,Text="FPS: --\nMemory: -- MB\nPing: -- ms",Parent=f}); local last=os.clock(); local frames=0; local con; con=RunService.RenderStepped:Connect(function() frames+=1; local now=os.clock(); if now-last>=.5 then local fps=math.floor(frames/(now-last)+.5); frames=0; last=now; local mem=math.floor(Stats:GetTotalMemoryUsageMb()+.5); label.Text="FPS: "..fps.."\nMemory: "..mem.." MB\nPing: -- ms" end end); table.insert(self.Connections,con) end}) end); pcallr(function() tab:Button({Title="Play Transition",Icon=self.Icons.Visuals,Callback=function() local tr=self:Transition(); if tr then tr:Pulse() end end}) end) end

	function Sentry:BuildShowcase()
		self:SetMotionProfile("Balanced"); self:UseTheme("Aurora"); self:LiveBackground(); self:Intro()
		local window=self:CreateWindow(); if not window then return nil end
		local main=pcallr(function() return window:Tab({Title="Main",Desc="Overview",Icon=self.Icons.Home,Border=true}) end)
		local elements=pcallr(function() return window:Tab({Title="Elements",Desc="Components",Icon=self.Icons.Elements,Border=true}) end)
		local visuals=pcallr(function() return window:Tab({Title="Visuals",Desc="Transitions",Icon=self.Icons.Visuals,Border=true}) end)
		local themes=pcallr(function() return window:Tab({Title="Themes",Desc="Theme studio",Icon=self.Icons.Themes,Border=true}) end)
		local friends=pcallr(function() return window:Tab({Title="Friends",Desc="Friend system",Icon=self.Icons.Friends,Border=true}) end)
		local security=pcallr(function() return window:Tab({Title="Key System",Desc="Access",Icon=self.Icons.Key,Border=true}) end)
		local settings=pcallr(function() return window:Tab({Title="Settings",Desc="Performance",Icon=self.Icons.Settings,Border=true}) end)
		local about=pcallr(function() return window:Tab({Title="About",Desc="Info",Icon="info",Border=true}) end)
		if main then pcallr(function() main:Section({Title="Sentry Hub Library",TextSize=24,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() main:Paragraph({Title="Production UI system online",Desc="Production transitions, avatar profile data, advanced console logging, live backgrounds, image backgrounds, friend stats, theme studio, key system, and performance tooling."}) end); self:AvatarViewportCard(main); pcallr(function() main:Button({Title="Test Production Notification",Icon=self.Icons.Bell,Callback=function() self:Notify("Success","Sentry Hub Library","Production systems are running.") end}) end) end
		self:BuildElements(elements); self:BuildVisuals(visuals); self:BuildThemes(themes,window); self:BuildFriends(friends); self:BuildSecurity(security); self:BuildSettings(settings)
		if about then pcallr(function() about:Section({Title="About Sentry Hub Library",TextSize=24,FontWeight=Enum.FontWeight.SemiBold}) end); pcallr(function() about:Paragraph({Title="Production Grade Interface Framework",Desc="Sentry adds advanced intro, console logs, live backgrounds, avatar viewport, friend stats, key system, premium transitions, theme studio, icons, and performance tools.\nVersion: "..self.Version}) end) end
		self:Notify("Success","Sentry Hub Library","Production showcase loaded."); return window
	end

	function Sentry:Destroy() for _,con in ipairs(self.Connections) do pcall(function() con:Disconnect() end) end; for _,g in ipairs(self.Guis) do pcall(function() g:Destroy() end) end; table.clear(self.Connections); table.clear(self.Guis) end

	WindUI.SentryHub = Sentry; WindUI.SentryProduction = Sentry; WindUI.GodTierPlus = Sentry
	WindUI.CreateSentryShowcase = function(_) return Sentry:BuildShowcase() end
	WindUI.CreateSentryWindow = function(_,cfg) return Sentry:CreateWindow(cfg) end
	WindUI.CreateSentryIntro = function(_,cfg) return Sentry:Intro(cfg) end
	WindUI.CreateSentryConsole = function(_,cfg) return Sentry:Console(cfg) end
	WindUI.CreateSentryTransition = function(_,cfg) return Sentry:Transition(cfg) end
	WindUI.CreateSentryLiveBackground = function(_,cfg) return Sentry:LiveBackground(cfg) end
	WindUI.CreateSentryImageBackground = function(_,cfg) return Sentry:ImageBackground(cfg) end
	WindUI.CreateSentryAvatarViewport = function(_,cfg) return Sentry:AvatarViewportCard(nil,cfg) end
	WindUI.CreateSentryKeySystem = function(_,cfg) return Sentry:AdvancedKeySystem(cfg) end
	WindUI.GetSentryFriendSummary = function(_) return Sentry:FriendSummary() end
	WindUI.SetSentryMotionProfile = function(_,name) return Sentry:SetMotionProfile(name) end
	WindUI.NotifyInfo = function(_,title,text,duration) return Sentry:Notify("Info",title,text,duration) end
	WindUI.NotifySuccess = function(_,title,text,duration) return Sentry:Notify("Success",title,text,duration) end
	WindUI.NotifyWarning = function(_,title,text,duration) return Sentry:Notify("Warning",title,text,duration) end
	WindUI.NotifyError = function(_,title,text,duration) return Sentry:Notify("Error",title,text,duration) end
	WindUI.CreateGodTierShowcase = WindUI.CreateSentryShowcase
	WindUI.CreateGodTierWindow = WindUI.CreateSentryWindow
	return Sentry
end
