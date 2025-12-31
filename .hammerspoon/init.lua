-- Global config
hs.window.animationDuration = 0

-- -- Super App Switcher Spoon
-- local okSuper = pcall(hs.loadSpoon, "SuperAppSwitcher")
-- if okSuper and spoon.SuperAppSwitcher then
-- 	-- Wanted Rectangle Pro to handle window management, but there seems to be
-- 	-- a bug where restoring a an app layout's dimensions will shrink it slightly
-- 	spoon.SuperAppSwitcher:start()
-- else
-- 	hs.alert.show("SuperAppSwitcher.spoon not found")
-- end

-- -- Skim Vim Navigation Spoon
local okSkim = pcall(hs.loadSpoon, "SkimVimNav")
if okSkim and spoon.SkimVimNav then
	spoon.SkimVimNav:start()
else
	hs.alert.show("SkimVimNav.spoon not found")
end

-- Simple reload hotkey
local SUPER = { "shift", "ctrl", "alt" }
hs.hotkey.bind(SUPER, "R", function()
	hs.reload()
	hs.alert.show("Hammerspoon config reloaded")
end)
