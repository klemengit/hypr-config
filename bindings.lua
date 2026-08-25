-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- SUPER+ALT+RETURN was bound to "Tmux" (omarchy-launch-terminal-tmux), which
-- always opened a new terminal client attached to the tmux session. Rebind it
-- to focus the existing tagged tmux terminal window if one is already open.
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + ALT + RETURN", "Tmux", { focus = "org.omarchy.terminal-tmux", launch = "omarchy-launch-terminal-tmux-tagged" })

-- SUPER+SHIFT+RETURN and SUPER+SHIFT+B were both bound to "Browser"
-- (omarchy-launch-browser), which always opens a new browser window. Rebind
-- both to focus an existing browser window instead, using the same class
-- pattern Omarchy's own browser.lua uses to tag chromium/firefox windows.
-- SUPER+SHIFT+ALT+B (private browsing) is left as always-new, on purpose.
local browser_class_pattern = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium|[fF]irefox|zen|librewolf)"
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + RETURN", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })
o.bind("SUPER + SHIFT + B", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })

-- Omakub-style app switcher: Alt+1-4 focus-or-launch a fixed set of apps.
-- Reuses the browser_class_pattern and tagged tmux launcher defined above.
o.bind("ALT + 1", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })
o.bind("ALT + 2", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
o.bind("ALT + 3", "File manager", { focus = "^org.gnome.Nautilus$", launch = "nautilus" })
o.bind("ALT + 4", "Tmux", { focus = "org.omarchy.terminal-tmux", launch = "omarchy-launch-terminal-tmux-tagged" })
o.bind("ALT + 7", "Signal", { omarchy = "signal" })
o.bind("ALT + 8", "Activity", { tui = "btop" })

-- SUPER+H/L move the active WINDOW (not the whole workspace) to the
-- neighboring monitor, matching the hjkl direction feel from the Ferris
-- Sweep layout. Not workspace cycling (SUPER+TAB already does that, and
-- workspace numbers aren't part of this workflow) - this is "move what I'm
-- looking at to the other screen". hl.dsp.window.move({ monitor = ... })
-- isn't documented anywhere (no Lua source available to read, and
-- `hyprctl dispatch movewindow mon:l` - the vanilla Hyprland syntax -
-- doesn't work on this Lua-scripted build); found by testing
-- `hyprctl dispatch 'hl.dsp.window.move({monitor="l"})'` directly and
-- confirming with `hyprctl activewindow -j` that only the focused window's
-- monitor changed, workspace membership untouched. Monitors here are laid
-- out left-to-right only, so J/K (up/down) are skipped - no vertical
-- monitor to move to. SUPER+H was unbound by default. SUPER+L was bound to
-- "Toggle workspace layout" (dwindle/master), which isn't used here.
hl.unbind("SUPER + L")
o.bind("SUPER + H", "Move window to left monitor", hl.dsp.window.move({ monitor = "l" }))
o.bind("SUPER + L", "Move window to right monitor", hl.dsp.window.move({ monitor = "r" }))

-- SUPER+SHIFT+H/L move the whole current WORKSPACE to a monitor (as opposed
-- to SUPER+H/L above, which moves just the active window). Together with
-- the default SUPER+SHIFT+1-9 ("move window to workspace N"), this covers
-- the full app-arranging workflow: move a window to the workspace slot you
-- want it in, then move that workspace to the monitor you want it showing
-- on. Same dispatcher Omarchy's own SUPER+SHIFT+ALT+arrow bindings use.
o.bind("SUPER + SHIFT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))

-- Remove all of Omarchy's preinstalled webapp bindings (ChatGPT, Grok,
-- Calendar, Email, YouTube, WhatsApp, Google Messages/Photos/Maps, X).
-- These apps already have real .desktop entries in
-- ~/.local/share/applications/, so SUPER+SPACE (Omarchy menu / launcher
-- search) still finds and opens them by name - only the dedicated hotkeys
-- are gone.
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + ALT + A")
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + ALT + E")
hl.unbind("SUPER + SHIFT + Y")
hl.unbind("SUPER + SHIFT + ALT + G")
hl.unbind("SUPER + SHIFT + CTRL + G")
hl.unbind("SUPER + SHIFT + P")
hl.unbind("SUPER + SHIFT + S")
hl.unbind("SUPER + SHIFT + X")
hl.unbind("SUPER + SHIFT + ALT + X")

-- Screenshot: rebind from PRINT (unreachable - not mapped anywhere on the
-- Ferris Sweep) to SUPER+SHIFT+S (freed up by removing the Google Maps
-- webapp binding above).
hl.unbind("PRINT")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
