hs.window.animationDuration = 0
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
	["5"] = { name = "Sioyek", id = "com.github.ahrm.sioyek", group = "latex" },
	["6"] = { name = "Safari", id = "com.apple.Safari" },
}
local pending = {}
local lastPressAt = {}
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
			-- Skip if target is in a group and this app is in the same group
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
	-- Collect all screens where group apps are present
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

	-- Hide all non-group apps on those screens
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
	local frontId = front and front:bundleID()

	-- Only trigger group behavior if this target is a group_leader
	local groupActive = target.group_leader and target.group and isGroupActive(target.group)
	local groupApps = groupActive and getGroupApps(target.group) or {}

	-- Check if the TARGET APP ITSELF is frontmost (not just any app in the group)
	local targetIsFront = front and (frontId == target.id or front:name() == target.name)

	if HIDE_ON_SAME_KEY and targetIsFront then
		if groupActive then
			-- Hide all apps in the group
			for _, gApp in ipairs(groupApps) do
				gApp:hide()
			end
		else
			front:hide()
		end
		return
	end

	-- Show/activate apps
	if groupActive then
		-- Unhide and activate ALL group apps
		for _, gApp in ipairs(groupApps) do
			gApp:unhide()
			gApp:activate(false)
		end
		-- Focus the target app last
		local app = getApp(target)
		if app then
			app:activate(false)
		end
	else
		local app = getApp(target)
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
			-- Wait for the target app to be ready, then handle group behavior
			waitForApp(a, 0.6, function()
				local tw = mainWin(a)
				if tw then
					tw:focus()
				end

				-- ALWAYS hide other apps when the group is brought up together
				hideOthersForGroup(groupApps, target.group)
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
for key, target in pairs(apps) do
	hs.hotkey.bind(SUPER, key, function()
		focusApp(target, key)
	end)
end
local function hideAllExcept(app)
	local appGroup = isInGroup(app)
	for _, a in ipairs(hs.application.runningApplications()) do
		if a ~= app and a:isRunning() and not a:isHidden() then
			-- Don't hide if it's in the same group as the front app
			if appGroup and isInGroup(a) == appGroup then
				goto continue
			end
			a:hide()
			::continue::
		end
	end
end
local rectMaxHotkey
rectMaxHotkey = hs.hotkey.bind(SUPER, "f", function()
	local front = hs.application.frontmostApplication()
	if front then
		hideAllExcept(front)
	end
	rectMaxHotkey:disable()
	hs.eventtap.keyStroke(SUPER, "f", 0)
	rectMaxHotkey:enable()
end)
hs.hotkey.bind(SUPER, "R", function()
	for k, t in pairs(pending) do
		if t then
			t:stop()
		end
		pending[k] = nil
	end
	hs.reload()
	hs.alert.show("Config reloaded")
end)
