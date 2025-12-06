local obj = {}
obj.__index = obj

obj.name = "SuperAppSwitcher"
obj.version = "0.1"
obj.author = "wkflanders"
obj.license = "MIT"

local SUPER = { "shift", "ctrl", "alt" }
local PSEUDO_FULLSCREEN_GAP = 30
local EDGE_TOLERANCE = 4
local HIDE_ON_SAME_KEY = true
local DEBOUNCE_MS = 120

local apps = {
	["1"] = { name = "Alacritty", id = "org.alacritty", group = "latex", group_leader = true },
	["2"] = { name = "Zen", id = "app.zen-browser.zen" },
	["3"] = { name = "Messages", id = "com.apple.iChat" },
	["4"] = { name = "Spotify", id = "com.spotify.client" },
	["5"] = { name = "Skim", id = "net.sourceforge.skim-app.skim", group = "latex" },
	["6"] = { name = "Safari", id = "com.apple.Safari" },
	["9"] = { name = "Stickies", id = "com.apple.Stickies" },
	["0"] = { name = "Zotero", id = "org.zotero.zotero" },
	["`"] = { name = "Finder", id = "com.apple.finder" },
	["O"] = { name = "Obsidian", id = "md.obsidian" },
	["P"] = { name = "Orbstack", id = "dev.kdrag0n.MacVirt" },
}

local pending = {}
local lastPressAt = {}
local rectMaxHotkey = nil

obj.hotkeys = {}

local function now_ms()
	return hs.timer.absoluteTime() / 1e6
end

local function getApp(target)
	return target.id and hs.application.get(target.id) or hs.appfinder.appFromName(target.name)
end

local function mainWin(app)
	if not app or not app:isRunning() then
		return nil
	end
	local win = app:mainWindow()
	if win and win:isMinimized() then
		win:unminimize()
	end
	return win
end

local function isAppReady(app)
	if not app then
		return false
	end
	local win = app:mainWindow()
	return win and (app:isFrontmost() or win:isStandard())
end

local function waitForApp(app, timeoutSec, cb)
	if isAppReady(app) then
		cb()
		return
	end
	local deadline = hs.timer.absoluteTime() + (timeoutSec * 1e9)
	local t
	t = hs.timer.doEvery(0.02, function()
		if isAppReady(app) or hs.timer.absoluteTime() > deadline then
			if t then
				t:stop()
				t = nil
			end
			cb()
		end
	end)
end

local function isPseudoFullscreen(win, gap, tol)
	if not win then
		return false
	end
	local screen = win:screen()
	if not screen then
		return false
	end

	local sf = screen:frame()
	local wf = win:frame()

	local leftOK = (wf.x - sf.x) <= (gap + tol)
	local topOK = (wf.y - sf.y) <= (gap + tol)
	local rightOK = ((sf.x + sf.w) - (wf.x + wf.w)) <= (gap + tol)
	local bottomOK = ((sf.y + sf.h) - (wf.y + wf.h)) <= (gap + tol)

	return leftOK and topOK and rightOK and bottomOK
end

local function getGroupApps(group)
	local groupApps = {}
	for _, t in pairs(apps) do
		if t.group == group then
			local app = getApp(t)
			if app and app:isRunning() then
				table.insert(groupApps, app)
			end
		end
	end
	return groupApps
end

local function isGroupActive(group)
	local groupApps = getGroupApps(group)
	return #groupApps > 1
end

local function isInGroup(targetApp)
	for _, t in pairs(apps) do
		if t.group then
			local app = getApp(t)
			if app == targetApp then
				return t.group
			end
		end
	end
	return nil
end

local function focusNextVisibleApp()
	local allWindows = hs.window.orderedWindows()
	for _, win in ipairs(allWindows) do
		local app = win:application()
		if app and not app:isHidden() and win:isStandard() then
			win:focus()
			return
		end
	end
end

local function hidePeersOnSameScreen(targetApp)
	local tWin = mainWin(targetApp)
	if not tWin then
		return
	end

	local tScreen = tWin:screen()
	local targetGroup = isInGroup(targetApp)

	for _, t in pairs(apps) do
		local a = getApp(t)
		if a and a ~= targetApp and a:isRunning() and not a:isHidden() then
			if targetGroup and t.group == targetGroup then
				goto continue
			end
			local w = mainWin(a)
			if w and w:isStandard() and w:screen() == tScreen then
				a:hide()
			end
			::continue::
		end
	end
end

local function hideOthersForGroup(groupApps, groupName)
	local groupScreens = {}
	for _, gApp in ipairs(groupApps) do
		local gWin = mainWin(gApp)
		if gWin then
			local screen = gWin:screen()
			if screen then
				groupScreens[screen:id()] = screen
			end
		end
	end

	for _, t in pairs(apps) do
		if t.group ~= groupName then
			local a = getApp(t)
			if a and a:isRunning() and not a:isHidden() then
				local w = mainWin(a)
				if w and w:isStandard() then
					local wScreen = w:screen()
					if wScreen and groupScreens[wScreen:id()] then
						a:hide()
					end
				end
			end
		end
	end
end

local function hideAllExcept(app)
	local appGroup = isInGroup(app)
	for _, t in pairs(apps) do
		local a = getApp(t)
		if a and a ~= app and a:isRunning() and not a:isHidden() then
			if appGroup and isInGroup(a) == appGroup then
				goto continue
			end
			a:hide()
			::continue::
		end
	end
end

local function getAlphabeticalApps()
	local running = hs.application.runningApplications()
	local list = {}
	for _, app in ipairs(running) do
		if app:bundleID() and app:name() and app:name() ~= "" then
			local w = app:mainWindow()
			if w then
				table.insert(list, app)
			end
		end
	end
	table.sort(list, function(a, b)
		return a:name() < b:name()
	end)
	return list
end

local function cycleGlobalApp(offset, keyId)
	local candidates = getAlphabeticalApps()
	local n = #candidates
	if n == 0 then
		return
	end

	local t0 = lastPressAt[keyId] or 0
	local t1 = now_ms()
	if (t1 - t0) < DEBOUNCE_MS then
		return
	end
	lastPressAt[keyId] = t1

	local front = hs.application.frontmostApplication()
	local currentIndex = 1
	if front then
		for i, app in ipairs(candidates) do
			if app == front then
				currentIndex = i
				break
			end
		end
	end

	local newIndex = ((currentIndex - 1 + offset) % n) + 1
	local targetApp = candidates[newIndex]
	if not targetApp then
		return
	end

	targetApp:unhide()
	targetApp:activate(false)

	hs.timer.doAfter(0.03, function()
		local win = mainWin(targetApp)
		if win then
			win:focus()
			if isPseudoFullscreen(win, PSEUDO_FULLSCREEN_GAP, EDGE_TOLERANCE) then
				hidePeersOnSameScreen(targetApp)
			end
		end
	end)
end

local function focusApp(target, hotkey)
	local t0 = lastPressAt[hotkey] or 0
	local t1 = now_ms()
	if (t1 - t0) < DEBOUNCE_MS then
		return
	end
	lastPressAt[hotkey] = t1

	local prevTimer = pending[hotkey]
	if prevTimer then
		prevTimer:stop()
		pending[hotkey] = nil
	end

	local front = hs.application.frontmostApplication()
	local app = getApp(target)

	local groupActive = target.group_leader and target.group and isGroupActive(target.group)
	local groupApps = groupActive and getGroupApps(target.group) or {}

	local targetIsFront = app and front and (app == front)

	if HIDE_ON_SAME_KEY and targetIsFront then
		if groupActive then
			for _, gApp in ipairs(groupApps) do
				gApp:hide()
			end
		else
			app:hide()
		end
		focusNextVisibleApp()
		return
	end

	if groupActive then
		for _, gApp in ipairs(groupApps) do
			gApp:unhide()
		end

		for _, gApp in ipairs(groupApps) do
			local gWin = mainWin(gApp)
			if gWin then
				gWin:raise()
			end
		end

		if app then
			app:activate(true)
		end

		hideOthersForGroup(groupApps, target.group)
	else
		if app and app:isRunning() then
			app:unhide()
			app:activate(false)
		else
			if target.id then
				hs.application.launchOrFocusByBundleID(target.id)
			else
				hs.application.launchOrFocus(target.name)
			end
		end
	end

	local timer = hs.timer.delayed.new(0.03, function()
		pending[hotkey] = nil
		local a = getApp(target)
		if not a then
			return
		end

		if groupActive then
			waitForApp(a, 0.6, function()
				local tw = mainWin(a)
				if tw then
					tw:focus()
				end
			end)
		else
			waitForApp(a, 0.6, function()
				local tw = mainWin(a)
				if tw then
					tw:focus()
				end
				if isPseudoFullscreen(tw, PSEUDO_FULLSCREEN_GAP, EDGE_TOLERANCE) then
					hidePeersOnSameScreen(a)
				end
			end)
		end
	end)

	pending[hotkey] = timer
	timer:start()
end

function obj:start()
	for key, target in pairs(apps) do
		self.hotkeys[key] = hs.hotkey.bind(SUPER, key, function()
			focusApp(target, key)
		end)
	end

	self.hotkeys["cyclePrev"] = hs.hotkey.bind(SUPER, "Q", function()
		cycleGlobalApp(-1, "Q")
	end)

	self.hotkeys["cycleNext"] = hs.hotkey.bind(SUPER, "E", function()
		cycleGlobalApp(1, "E")
	end)

	rectMaxHotkey = hs.hotkey.bind(SUPER, "f", function()
		local front = hs.application.frontmostApplication()

		rectMaxHotkey:disable()
		hs.eventtap.keyStroke(SUPER, "f", 0)
		rectMaxHotkey:enable()

		if front then
			hs.timer.doAfter(0.1, function()
				hideAllExcept(front)
			end)
		end
	end)
	self.hotkeys["rectMax"] = rectMaxHotkey

	return self
end

function obj:stop()
	for _, hk in pairs(self.hotkeys) do
		hk:delete()
	end
	self.hotkeys = {}

	for k, t in pairs(pending) do
		if t then
			t:stop()
		end
		pending[k] = nil
	end

	return self
end

return obj
