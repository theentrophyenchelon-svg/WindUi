--[[
	Sentry Hub Library - Presence Count Patch
	Improves the online count using Roblox client-exposed presence data.
]]

return function(WindUI, Sentry)
	if type(Sentry) ~= "table" then
		return Sentry
	end
	if Sentry.PresenceCountPatchInstalled then
		return Sentry
	end

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	Sentry.PresenceCountPatchInstalled = true

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		return nil, result
	end

	function Sentry:GetPresenceCount()
		if not LocalPlayer then
			return 0, "No local player"
		end
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
		local count, err = self:GetPresenceCount()
		local note = "\n\nPresence Count: " .. count
		if err then
			note ..= "\nPresence Diagnostics: " .. err
		end
		return base .. note
	end

	return Sentry
end
