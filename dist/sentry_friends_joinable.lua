--[[
	Sentry Hub Library - Friend Presence Panel
	Shows online Roblox friends with public join actions only when Roblox exposes join data.
]]

return function(WindUI, Sentry)
	if type(WindUI) ~= "table" or type(Sentry) ~= "table" then
		return Sentry
	end
	if Sentry.FriendJoinablePatchInstalled then
		return Sentry
	end

	local Players = game:GetService("Players")
	local TeleportService = game:GetService("TeleportService")
	local LocalPlayer = Players.LocalPlayer

	Sentry.FriendJoinablePatchInstalled = true
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Friends = Sentry.Icons.Friends or "users"
	Sentry.Icons.Refresh = Sentry.Icons.Refresh or "refresh-cw"
	Sentry.Icons.Join = Sentry.Icons.Join or "log-in"
	Sentry.OnlineFriendRows = {}
	Sentry.OnlineFriendTargets = {}

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Friends]", result)
		return nil
	end

	local function notify(kind, title, content, duration)
		local method = WindUI.NotifyInfo
		if kind == "Success" then method = WindUI.NotifySuccess end
		if kind == "Warning" then method = WindUI.NotifyWarning end
		if kind == "Error" then method = WindUI.NotifyError end
		if method then
			return safe(function() return method(WindUI, title, content, duration or 3) end)
		end
		return safe(function() return WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 }) end)
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

	function Sentry:GetOnlineFriendPresence()
		if not LocalPlayer then
			return {}, "No local player"
		end
		local ok, friends = pcall(function()
			return LocalPlayer:GetFriendsOnline(200)
		end)
		if not ok then
			return {}, tostring(friends)
		end
		local result = {}
		for _, friend in ipairs(friends or {}) do
			local placeId = tonumber(friend.PlaceId or friend.PlaceID)
			local jobId = friend.GameId or friend.GameID or friend.JobId or friend.JobID
			if jobId == "" then jobId = nil end
			table.insert(result, {
				UserId = tonumber(friend.VisitorId or friend.UserId or friend.Id),
				Username = tostring(friend.UserName or friend.Username or friend.Name or "Unknown"),
				DisplayName = tostring(friend.DisplayName or friend.UserName or friend.Username or "Unknown"),
				LastLocation = tostring(friend.LastLocation or friend.Location or "Unknown location"),
				PlaceId = placeId,
				JobId = jobId,
			})
		end
		return result, nil
	end

	function Sentry:FriendRowText(friend, index)
		if not friend then
			return "Slot " .. index .. " waiting for Roblox online presence data."
		end
		local joinable = friend.PlaceId ~= nil
		return "Username: @" .. friend.Username .. "\nDisplay Name: " .. friend.DisplayName .. "\nLocation: " .. friend.LastLocation .. "\nPlace ID: " .. tostring(friend.PlaceId or "Hidden") .. "\nServer Job ID: " .. tostring(friend.JobId or "Hidden") .. "\nJoin Available: " .. tostring(joinable)
	end

	function Sentry:RefreshFriendPresencePanel()
		local online, err = self:GetOnlineFriendPresence()
		self.OnlineFriendTargets = online
		local joinable = 0
		for _, friend in ipairs(online) do
			if friend.PlaceId then joinable += 1 end
		end
		local summary = "Presence Online Count: " .. #online .. "\nPublic Join Targets: " .. joinable
		if err then summary ..= "\nDiagnostics: " .. err end
		setParagraph(self.Refs.Friends, "Online Friend Presence", summary)
		for i = 1, 12 do
			local friend = online[i]
			local title = friend and (friend.DisplayName .. "  @" .. friend.Username) or ("Online Friend Slot " .. i)
			setParagraph(self.OnlineFriendRows[i], title, self:FriendRowText(friend, i))
		end
	end

	function Sentry:JoinOnlineFriend(index)
		local friend = self.OnlineFriendTargets[index]
		if not friend then
			notify("Warning", "No Friend", "No online friend is assigned to this slot yet.", 3)
			return
		end
		if not friend.PlaceId then
			notify("Warning", "Join Unavailable", "Roblox did not expose a public place for " .. friend.DisplayName .. ".", 4)
			return
		end
		if friend.JobId then
			safe(function() TeleportService:TeleportToPlaceInstance(friend.PlaceId, friend.JobId, LocalPlayer) end)
		else
			safe(function() TeleportService:Teleport(friend.PlaceId, LocalPlayer) end)
		end
	end

	function Sentry:BuildFriends(tab)
		if not tab then return end
		safe(function() tab:Section({ Title = "Friend System", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.Friends = tab:Paragraph({
				Title = "Online Friend Presence",
				Desc = "Loading Roblox online presence...",
				Image = self.Icons.Friends,
				Buttons = {
					{ Title = "Refresh", Icon = self.Icons.Refresh, Callback = function() self:RefreshFriendPresencePanel() end },
				},
			})
		end)
		safe(function() tab:Section({ Title = "Online Friends", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		self.OnlineFriendRows = {}
		for i = 1, 12 do
			safe(function()
				self.OnlineFriendRows[i] = tab:Paragraph({
					Title = "Online Friend Slot " .. i,
					Desc = self:FriendRowText(nil, i),
					Image = self.Icons.Friends,
					Buttons = {
						{ Title = "Join", Icon = self.Icons.Join, Callback = function() self:JoinOnlineFriend(i) end },
					},
				})
			end)
		end
		self:RefreshFriendPresencePanel()
	end

	return Sentry
end
