local obj = {}
obj.__index = obj

obj.name = "MenuBarTransparency"
obj.version = "0.1"
obj.license = "MIT"

obj.menubar = nil

-- Read current state of NSDisableMenuBarTransparency
function obj:isOpaque()
	local ok, result = pcall(
		hs.execute,
		"defaults read -g NSDisableMenuBarTransparency 2>/dev/null",
		true -- with_user_env
	)
	if not ok or not result then
		return false
	end
	result = result:gsub("%s+", ""):lower()
	return (result == "1" or result == "true")
end

-- Write the setting and restart Dock to apply
function obj:setOpaque(opaque)
	if opaque then
		hs.execute("defaults write -g NSDisableMenuBarTransparency -bool true", true)
	else
		-- delete key; ignore error if it doesn't exist
		hs.execute("defaults delete -g NSDisableMenuBarTransparency 2>/dev/null || true", true)
	end
	-- Dock restart applies the change to the menu bar
	hs.execute("killall Dock 2>/dev/null || true", true)
end

function obj:updateMenu()
	if not self.menubar then
		return
	end

	local opaque = self:isOpaque()
	local stateText = opaque and "Opaque" or "Transparent"

	self.menubar:setTooltip("Menu Bar Transparency (" .. stateText .. ")")

	self.menubar:setMenu({
		{
			title = opaque and "Switch to Transparent Menu Bar" or "Switch to Opaque Menu Bar",
			fn = function()
				self:setOpaque(not opaque)
				-- Wait a bit for Dock to restart, then refresh label
				hs.timer.doAfter(1.0, function()
					self:updateMenu()
				end)
			end,
		},
		{ title = "-" },
		{
			title = "Current: " .. stateText,
			disabled = true,
		},
	})
end

function obj:start()
	if self.menubar then
		return self
	end

	self.menubar = hs.menubar.new()
	if not self.menubar then
		hs.alert.show("MenuBarTransparency: failed to create menubar item")
		return self
	end

	self.menubar:setTitle("☱")

	self:updateMenu()
	return self
end

function obj:stop()
	if self.menubar then
		self.menubar:delete()
		self.menubar = nil
	end
	return self
end

return obj
