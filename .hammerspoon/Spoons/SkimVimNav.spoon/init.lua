local obj = {}
obj.__index = obj
obj.name = "SkimVimNav"
obj.version = "1.0"
obj.author = "wkflanders"
obj.license = "MIT"
obj.appWatcher = nil
obj.eventtap = nil
obj.scrollAmount = 128

local function isTextField()
	local focused = hs.uielement.focusedElement()
	if focused then
		local role = focused:role()
		return role == "AXTextField" or role == "AXTextArea" or role == "AXComboBox" or role == "AXSearchField"
	end
	return false
end

local function isAerospaceModifier(flags)
	if flags.ctrl and flags.alt and flags.shift then
		return true
	end
	return false
end

function obj:init()
	return self
end

function obj:createEventtap()
	return hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyRepeat }, function(event)
		local frontApp = hs.application.frontmostApplication()
		if not frontApp or frontApp:name() ~= "Skim" then
			return false
		end

		local flags = event:getFlags()
		if isTextField() then
			return false
		end
		if isAerospaceModifier(flags) then
			return false
		end

		local keycode = event:getKeyCode()
		local keyMap = hs.keycodes.map
		local actions = {
			[keyMap["j"]] = function()
				hs.eventtap.scrollWheel({ 0, -self.scrollAmount }, {}, "pixel")
				return true
			end,
			[keyMap["k"]] = function()
				hs.eventtap.scrollWheel({ 0, self.scrollAmount }, {}, "pixel")
				return true
			end,
			[keyMap["h"]] = function()
				hs.eventtap.keyStroke({}, "left", 0)
				return true
			end,
			[keyMap["l"]] = function()
				hs.eventtap.keyStroke({}, "right", 0)
				return true
			end,
			[keyMap["d"]] = function()
				hs.eventtap.keyStroke({}, "space", 0)
				return true
			end,
			[keyMap["u"]] = function()
				hs.eventtap.keyStroke({ "shift" }, "space", 0)
				return true
			end,
			[keyMap["["]] = function()
				if flags.shift then
					hs.eventtap.keyStroke({}, "pageup", 0)
					return true
				end
				return false
			end,
			[keyMap["]"]] = function()
				if flags.shift then
					hs.eventtap.keyStroke({}, "pagedown", 0)
					return true
				end
				return false
			end,
		}

		local action = actions[keycode]
		if action then
			return action()
		end
		return false
	end)
end

function obj:enableEventtap()
	if not self.eventtap then
		self.eventtap = self:createEventtap()
	end
	self.eventtap:start()
end

function obj:disableEventtap()
	if self.eventtap then
		self.eventtap:stop()
	end
end

function obj:start()
	self.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
		if eventType == hs.application.watcher.activated then
			if appName == "Skim" then
				self:enableEventtap()
			else
				self:disableEventtap()
			end
		end
	end)
	self.appWatcher:start()
	if hs.application.frontmostApplication():name() == "Skim" then
		self:enableEventtap()
	end
	return self
end

function obj:stop()
	if self.appWatcher then
		self.appWatcher:stop()
		self.appWatcher = nil
	end
	self:disableEventtap()
	return self
end

function obj:setScrollAmount(amount)
	self.scrollAmount = amount
	return self
end

return obj
