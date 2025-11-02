hs.window.animationDuration = 0

local SUPER = { "shift", "ctrl", "alt" }
local apps = {
	["1"] = { name = "Alacritty", id = "org.alacritty" },
	["2"] = { name = "Zen", id = "app.zen-browser.zen" },
	["3"] = { name = "Messages", id = "com.apple.iChat" },
	["4"] = { name = "Spotify", id = "com.spotify.client" },
}

local function getApp(target)
	return target.id and hs.application.get(target.id) or hs.appfinder.appFromName(target.name)
end

local function isAppReady(app)
	if not app then
		return false
	end
	local win = app:mainWindow()
	return win and (app:isFrontmost() or win:isStandard())
end

local function waitForApp(app, timeoutSec, callback)
	if isAppReady(app) then
		callback()
		return
	end

	local deadline = hs.timer.absoluteTime() + (timeoutSec * 1e9)
	local ticker
	ticker = hs.timer.doEvery(0.02, function()
		if isAppReady(app) or hs.timer.absoluteTime() > deadline then
			ticker:stop()
			callback()
		end
	end)
end

local function toggleApp(target)
	local prev = hs.application.frontmostApplication()
	local prevId = prev and prev:bundleID()

	if prev and (prevId == target.id or prev:name() == target.name) then
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

		waitForApp(app, 0.5, function()
			if prev and prev:isRunning() and prev ~= app then
				prev:hide()
			end

			local win = app:mainWindow()
			if win then
				win:focus()
			end
		end)
	end)
end

for key, target in pairs(apps) do
	hs.hotkey.bind(SUPER, key, function()
		toggleApp(target)
	end)
end

hs.hotkey.bind(SUPER, "R", function()
	hs.reload()
	hs.alert.show("Config reloaded")
end)
