--[[
	Sentry Hub Library - Theme Restore
	Restores the full theme list with clean default styling.
]]

return function(WindUI, Sentry)
	if type(Sentry) ~= "table" then return Sentry end
	if Sentry.ThemeRestoreInstalled then return Sentry end
	Sentry.ThemeRestoreInstalled = true
	Sentry.Refs = Sentry.Refs or {}
	Sentry.Icons = Sentry.Icons or {}
	Sentry.Icons.Themes = Sentry.Icons.Themes or "palette"

	local function safe(callback, ...)
		local ok, result = pcall(callback, ...)
		if ok then return result end
		warn("[Sentry Theme]", result)
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

	function Sentry:ThemeNames()
		return { "Dark", "Light", "Aurora", "Obsidian", "Cyber", "Royal", "Velvet", "Glacier", "Solar", "Eclipse", "Crimson", "Emerald" }
	end

	function Sentry:BuildThemes(tab, window)
		if not tab then return end
		safe(function() tab:Section({ Title = "Theme Studio", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			self.Refs.ThemeStatus = tab:Paragraph({ Title = "Theme System", Desc = "All themes are restored using Sentry's clean transparent/default styling.", Image = self.Icons.Themes })
		end)
		safe(function() tab:Section({ Title = "Theme Presets", TextSize = 22, FontWeight = Enum.FontWeight.SemiBold }) end)
		safe(function()
			tab:Dropdown({
				Title = "Active Theme",
				Values = self:ThemeNames(),
				Value = self.Theme or "Dark",
				Callback = function(value)
					self.Theme = tostring(value)
					safe(function() self:UseTheme(value) end)
					safe(function() window:SetTheme(value) end)
					setParagraph(self.Refs.ThemeStatus, "Theme System", "Active Theme: " .. tostring(value))
				end,
			})
		end)
		for _, name in ipairs(self:ThemeNames()) do
			safe(function()
				tab:Button({ Title = "Apply " .. name, Desc = "Switch to " .. name .. ".", Icon = self.Icons.Themes, Callback = function()
					self.Theme = name
					safe(function() self:UseTheme(name) end)
					safe(function() window:SetTheme(name) end)
					setParagraph(self.Refs.ThemeStatus, "Theme System", "Active Theme: " .. name)
				end })
			end)
		end
	end

	return Sentry
end
