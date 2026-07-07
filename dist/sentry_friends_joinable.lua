--[[
	Sentry Hub Library - Friend Presence Panel
	Replaces the old friend UI with presence counts, friend rows, and public-session join actions.
]]

return function(WindUI, Sentry)
	if type(WindUI) ~= "table" or type(Sentry) ~= "table" then
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
	Sentry.Icons.Copy = Sentry.Icons.Copy or "copy"
	Sentry.OnlineFriendRows = Sentry.OnlineFriendRows or {}
	Sentry.OnlineFriendTargets = Sentry.OnlineFriendTargets or {}

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return true, result end
		warn("[Sentry Friends]", result)
		return false, result
	end

	local function notify(kind, title, content, duration)
		local method = WindUI.NotifyInfo
		if kind == "Success" then method = WindUI.NotifySuccess end
		if kind == "Warning" then method = WindUI.NotifyWarning end
		if kind == "Error" then method = WindUI.NotifyError end
		if method then
			return pcall(function() method(WindUI, title, content, duration or 3) end)
		end
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

	function Sentry:GetTotalFriendCountAndServerFriends()
		local result = { Total = 0, InServer = {}, Error = nil }
		if not LocalPlayer then
			result.Error = "No local player"
			return result
		end

		local friendIds = {}
		local ok, pages = pcall(function()
			return Players:GetFriendsAsync(LocalPlayer.UserId)
		end)

		if not ok or not pages then
			result.Error = tostring(pages)
		else
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
				local advanced = pcall(function() pages:AdvanceToNextPageAsync() end)
				if not advanced then break end
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and friendIds[player.UserId] then
				table.insert(result.InServer, {
					UserId = player.UserId,
					Username = player.Name,
					DisplayName = player.DisplayName,
				})
			end
		end

		return result
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
			return "Waiting for Roblox online presence data for slot " .. index .. "."
		end

		local joinStatus = friend.PlaceId and "Available" or "Unavailable"
		return "Username: @" .. friend.Username
			.. "\nDisplay Name: " .. friend.DisplayName
			.. "\nLocation: " .. friend.LastLocation
			.. "\nPlace ID: " .. tostring(friend.PlaceId or "Not exposed")
			.. "\nServer Job ID: " .. tostring(friend.JobId or "Not exposed")
			.. "\nJoin: " .. joinStatus
	end

	function Sentry:FriendSummaryText()
		local totals = self:GetTotalFriendCountAndServerFriends()
		local online, onlineErr = self:GetOnlineFriendPresence()
		self.OnlineFriendTargets = online

		local publicTargets = 0
		for _, friend in ipairs(online) do
			if friend.PlaceId then publicTargets += 1 end
		end

		local lines = {
			"Total Friends: " .. totals.Total,
			"Friends in Server: " .. #totals.InServer,
			"Presence Online Count: " .. #online,
			"Public Join Targets: " .. publicTargets,
		}

		if totals.Error then table.insert(lines, "Friend Count Diagnostics: " .. totals.Error) end
		if onlineErr then table.insert(lines, "Presence Diagnostics: " .. onlineErr) end

		return table.concat(lines, "\n")
	end

	function Sentry:RefreshFriendPresencePanel()
		local summary = self:FriendSummaryText()
		setParagraph(self.Refs.Friends, "Friend System", summary)

		for i = 1, 15 do
			local friend = self.OnlineFriendTargets[i]
			local row = self.OnlineFriendRows[i]
			local title = friend and (friend.DisplayName .. "  @" .. friend.Username) or ("Online Friend Slot " .. i)
			setParagraph(row, title, self:FriendRowText(friend, i))
		end
	end

	function Sentry:JoinOnlineFriend(index)
		local friend = self.OnlineFriendTargets[index]
		if not friend then
			notify("Warning", "No Friend", "No online friend is assigned to this slot yet.", 3)
			return
		end

		if not friend.PlaceId then
			notify("Warning", "Join Unavailable", "Roblox did not expose a public joinable place for " .. friend.DisplayName .. ".", 4)
			return
		end

		notify("Info", "Joining Friend", "Attempting to join " .. friend.DisplayName .. "...", 3)

		local ok, err
		if friend.JobId then
			ok, err = safe(function()
				local options = Instance.new("TeleportOptions")
				options.ServerInstanceId = tostring(friend.JobId)
				TeleportService:TeleportAsync(friend.PlaceId, { LocalPlayer }, options)
			end)
			if not ok then
				ok, err = safe(function()
					TeleportService:TeleportToPlaceInstance(friend.PlaceId, tostring(friend.JobId), LocalPlayer)
				end)
			end
		else
			ok, err = safe(function()
				TeleportService:TeleportAsync(friend.PlaceId, { LocalPlayer })
			end)
			if not ok then
				ok, err = safe(function()
					TeleportService:Teleport(friend.PlaceId, LocalPlayer)
				end)
			end
		end

		if not ok then
			notify("Error", "Join Failed", tostring(err or "Teleport failed. The session may be private, full, restricted, or unavailable."), 5)
		end
	end

	function Sentry:BuildFriends(tab)
		if not tab then return end

		pcall(function()
			tab:Section({ Title = "Friend System", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		pcall(function()
			self.Refs.Friends = tab:Paragraph({
				Title = "Friend System",
				Desc = self:FriendSummaryText(),
				Image = self.Icons.Friends,
				Buttons = {
					{ Title = "Refresh", Icon = self.Icons.Refresh, Callback = function() self:RefreshFriendPresencePanel() end },
				},
			})
		end)

		pcall(function()
			tab:Section({ Title = "Online Friends", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold })
		end)

		self.OnlineFriendRows = {}
		for i = 1, 15 do
			pcall(function()
				self.OnlineFriendRows[i] = tab:Paragraph({
					Title = "Online Friend Slot " .. i,
					Desc = self:FriendRowText(self.OnlineFriendTargets[i], i),
					Image = self.Icons.Friends,
					Buttons = {
						{ Title = "Join", Icon = self.Icons.Join, Callback = function() self:JoinOnlineFriend(i) end },
					},
				})
			end)
		end

		self:RefreshFriendPresencePanel()
	end

	-- Critical: override the old production refresh path so it cannot restore Online: 0 / None detected.
	function Sentry:RefreshFriendPanels()
		self:RefreshFriendPresencePanel()
	end

	function Sentry:FriendText()
		return self:FriendSummaryText()
	end

	return Sentry
end
