hs.window.animationDuration = 0

local SUPER = { "shift", "ctrl", "alt" }

-- Config
local PSEUDO_FULLSCREEN_GAP = 30 -- your Rectangle gap
local EDGE_TOLERANCE = 4 -- fuzz for off-by-few-pixels

-- Behavior toggles
local HIDE_ON_SAME_KEY = false -- press same key to hide that app
-- (we never auto-hide on normal switches unless target is pseudo-fullscreen)

local apps = {
	["1"] = { name = "Alacritty", id = "org.alacritty" },
	["2"] = { name = "Zen", id = "app.zen-browser.zen" },
	["3"] = { name = "Messages", id = "com.apple.iChat" },
	["4"] = { name = "Spotify", id = "com.spotify.client" },
	["5"] = { name = "Preview", id = "com.apple.Preview" },
	["6"] = { name = "Safari", id = "com.apple.Safari" },
}

-- ───────────────────────── helpers ─────────────────────────
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
	local ticker
	ticker = hs.timer.doEvery(0.02, function()
		if isAppReady(app) or hs.timer.absoluteTime() > deadline then
			ticker:stop()
			cb()
		end
	end)
end

-- Return true if win fills the screen except for Rectangle-style margins
local function isPseudoFullscreen(win, gap, tol)
	if not win then
		return false
	end
	local screen = win:screen()
	if not screen then
		return false
	end
	local sf = screen:frame() -- visible frame (excludes menu bar/dock)
	local wf = win:frame()

	local leftOK = (wf.x - sf.x) <= (gap + tol)
	local topOK = (wf.y - sf.y) <= (gap + tol)
	local rightOK = ((sf.x + sf.w) - (wf.x + wf.w)) <= (gap + tol)
	local bottomOK = ((sf.y + sf.h) - (wf.y + wf.h)) <= (gap + tol)

	return leftOK and topOK and rightOK and bottomOK
end

-- Hide all other mapped apps that have a visible standard window on the same screen
local function hidePeersOnSameScreen(targetApp)
	local tWin = mainWin(targetApp)
	if not tWin then
		return
	end
	local tScreen = tWin:screen()
	for _, t in pairs(apps) do
		local a = getApp(t)
		if a and a ~= targetApp and a:isRunning() and not a:isHidden() then
			local w = mainWin(a)
			if w and w:isStandard() and w:screen() == tScreen then
				a:hide()
			end
		end
	end
end

-- ───────────────────────── logic ─────────────────────────
local function focusApp(target)
	local prev = hs.application.frontmostApplication()
	local prevId = prev and prev:bundleID()

	if HIDE_ON_SAME_KEY and prev and (prevId == target.id or prev:name() == target.name) then
		prev:hide()
		return
	end

	if target.id then
		hs.application.launchOrFocusByBundleID(target.id)
	else
		hs.application.launchOrFocus(target.name)
	end

	hs.timer.doAfter(0.01, function()
		local app = getApp(target)
		if not app then
			return
		end
		app:activate(true)

		waitForApp(app, 0.6, function()
			local tw = mainWin(app)
			if tw then
				tw:focus()
			end

			-- Key bit: if the target is Rectangle-"maximized" (with gaps),
			-- hide other mapped apps on the SAME SCREEN so nothing peeks in the margins.
			if isPseudoFullscreen(tw, PSEUDO_FULLSCREEN_GAP, EDGE_TOLERANCE) then
				hidePeersOnSameScreen(app)
			end
			-- Otherwise: focus-only, keep everything else visible (Rectangle handles layout)
		end)
	end)
end

for key, target in pairs(apps) do
	hs.hotkey.bind(SUPER, key, function()
		focusApp(target)
	end)
end
