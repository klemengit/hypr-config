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
-- to focus the existing tagged herdr terminal window if one is already open
-- (Omarchy's tmux replacement - migrated from tmux, which is no longer used).
hl.unbind("SUPER + ALT + RETURN")
o.bind("SUPER + ALT + RETURN", "Herdr", { focus = "org.omarchy.terminal-herdr", launch = "omarchy-launch-terminal-herdr-tagged" })

-- SUPER+SHIFT+RETURN and SUPER+SHIFT+B were both bound to "Browser"
-- (omarchy-launch-browser), which always opens a new browser window. Rebind
-- both to focus an existing browser window instead, using the same class
-- pattern Omarchy's own browser.lua uses to tag chromium/firefox windows.
-- SUPER+SHIFT+ALT+B (private browsing) is left as always-new, on purpose.
local browser_class_pattern = "((google-)?[cC]hrom(e|ium)|[bB]rave-(browser|origin)|[mM]icrosoft-edge|Vivaldi-stable|helium|[fF]irefox|zen|librewolf)"
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + RETURN", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })
o.bind("SUPER + SHIFT + B", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })

-- Omakub-style app switcher: Alt+1/3/4 focus-or-launch a fixed set of apps.
-- Reuses the browser_class_pattern and tagged herdr launcher defined above.
o.bind("ALT + 1", "Browser", { focus = browser_class_pattern, launch = "omarchy-launch-browser" })
o.bind("ALT + 3", "File manager", { focus = "^org.gnome.Nautilus$", launch = "nautilus" })
o.bind("ALT + 4", "Herdr", { focus = "org.omarchy.terminal-herdr", launch = "omarchy-launch-terminal-herdr-tagged" })
-- ALT+5 is the herdr session on linux-turbo, next to ALT+4's local one.
-- It gets its own window rather than a pane inside the local herdr, because
-- herdr refuses to nest by default ([experimental] allow_nested) and both
-- sides would fight over the ctrl+space prefix anyway. Its own app-id keeps
-- ALT+4 and ALT+5 from focusing each other's window. Plain terminals stay on
-- SUPER+RETURN.
o.bind("ALT + 5", "Turbo", { focus = "org.omarchy.terminal-turbo", launch = "launch-terminal-turbo" })
-- ALT+6 is the claude-swap live dashboard, focus-or-launch like ALT+4/ALT+5.
-- omarchy-launch-or-focus-tui derives the app-id from the command basename
-- ("org.omarchy.cswap") and tags the terminal with it, so repeat presses focus
-- the existing window instead of stacking up dashboards.
o.bind("ALT + 6", "cswap watch", "omarchy-launch-or-focus-tui cswap watch")

-- "Sometimes" apps (checked occasionally, not worth a permanent workspace
-- slot) live in their own named special workspace ("scratchpad") instead of
-- a normal focus-or-launch switch: reachable from any monitor/workspace with
-- one key, hidden the rest of the time, and the app keeps running in the
-- background between toggles. A window rule pins any matching window into
-- special:<name> as soon as it opens; the keybind toggles that workspace's
-- visibility and launches the app in the background the first time round,
-- if it isn't already running.
--
-- Deliberately no "silent" on the workspace assignment (unlike Omarchy's own
-- screen-share-preview rule in apps/browser.lua, which uses it to avoid
-- stealing focus for a popup nobody asked for) - here the workspace is
-- always toggled visible *before* the app can appear, and the whole point of
-- pressing the key is to interact with it immediately. "silent" turned out
-- to suppress focus entirely, not just the view-switch: the window would
-- show up on screen but keyboard input kept going to whatever was focused
-- before (caught via `hyprctl activewindow -j` while trying to type into
-- Obsidian's sign-in form and seeing Brave still reported as focused).
--
-- hl.dsp.workspace.toggle_special() can't be the binding's dispatcher
-- directly, because the shell command also needs to check whether the app
-- is already running first - so it's invoked via a raw
-- `hyprctl dispatch 'hl.dsp...(...)'` call inside the shell command instead.
-- That does work from a plain shell/CLI context (unlike the earlier
-- `movewindow mon:l` failure elsewhere in this file): the text after
-- `dispatch` just has to be valid Lua calling a real `hl.dsp.*` builder -
-- bare unquoted dispatcher syntax isn't, and neither is a quoted plain
-- string (`hl.dispatch: expected a dispatcher`), but `hl.dsp.foo("bar")`
-- itself is, and evaluates correctly.
local function bind_scratchpad(keys, description, name, class_pattern, launch_cmd)
  o.window(class_pattern, { workspace = "special:" .. name })
  o.bind(keys, description,
    "hyprctl dispatch 'hl.dsp.workspace.toggle_special(\"" .. name .. "\")'; "
      .. "hyprctl clients -j | jq -e '[.[] | select(.class | test(\""
      .. class_pattern .. "\"))] | length == 0' >/dev/null "
      .. "&& setsid uwsm-app -- " .. launch_cmd .. " >/dev/null 2>&1 &"
  )
end

bind_scratchpad("ALT + 7", "Signal", "signal", "^signal$", "signal-desktop")
bind_scratchpad("ALT + 9", "Bitwarden", "bitwarden", "^Bitwarden$", "bitwarden-desktop")
-- Activity (btop) used to be a plain { tui = "btop" } bind in the app
-- switcher above - always opened a *new* terminal, never focused an
-- existing one. omarchy-launch-tui tags the terminal window with app-id
-- "org.omarchy.<command>", so it slots into this same pattern like any
-- other app: singleton for free (no duplicate btop terminals), plus it now
-- hides/shows instead of piling up as just another tiled window.
bind_scratchpad("ALT + 8", "Activity", "activity", "^org.omarchy.btop$", "xdg-terminal-exec --app-id=org.omarchy.btop -e btop")
-- Obsidian's window class at open (matched by the rule below) is "obsidian",
-- but it relabels itself to "md.obsidian.Obsidian" once mapped - an
-- unanchored pattern is needed so the running-check (which reads the
-- *current* class from `hyprctl clients`) still recognizes it, or every
-- toggle press would launch a duplicate instance.
bind_scratchpad("ALT + 2", "Obsidian", "obsidian", "obsidian", "obsidian")

-- Obsidian opens floating at whatever small size/position it last
-- remembers (unlike Signal, which already tiles to fill the screen by
-- default) - `tile = true` didn't override this (Electron apps can force
-- floating via fixed min/max size hints Hyprland's windowrules can't
-- unset), so pin an explicit large centered size instead.
o.window("obsidian", { float = true, center = true, size = { 1500, 810 } })

-- SUPER+H/J/K/L move the active WINDOW (not the whole workspace) to the
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
-- out left-to-right only, so J/K (up/down) are dead binds for now (no
-- vertical monitor to move to) - added anyway for hjkl completeness, ready
-- for whenever a vertical monitor shows up. SUPER+H was unbound by default.
-- SUPER+L was bound to "Toggle workspace layout" (dwindle/master), and
-- SUPER+K to "Keybindings" (still reachable elsewhere via the menu) -
-- neither used here, both overwritten on purpose.
hl.unbind("SUPER + L")
hl.unbind("SUPER + K")
hl.unbind("SUPER + J") -- was "Toggle window split" - o.bind alone doesn't replace an existing default bind, both would fire
o.bind("SUPER + H", "Move window to left monitor", hl.dsp.window.move({ monitor = "l" }))
o.bind("SUPER + L", "Move window to right monitor", hl.dsp.window.move({ monitor = "r" }))
o.bind("SUPER + K", "Move window to up monitor", hl.dsp.window.move({ monitor = "u" }))
o.bind("SUPER + J", "Move window to down monitor", hl.dsp.window.move({ monitor = "d" }))

-- SUPER+SHIFT+H/J/K/L move the whole current WORKSPACE to a monitor (as
-- opposed to SUPER+H/J/K/L above, which moves just the active window).
-- Together with the default SUPER+SHIFT+1-9 ("move window to workspace N"),
-- this covers the full app-arranging workflow: move a window to the
-- workspace slot you want it in, then move that workspace to the monitor
-- you want it showing on. Same dispatcher Omarchy's own
-- SUPER+SHIFT+ALT+arrow bindings use. J/K are dead binds for now, same
-- reason as the SUPER+H/J/K/L block above.
o.bind("SUPER + SHIFT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))

-- Keybinding review pass: removing Omarchy defaults that either duplicate a
-- scratchpad binding above (Obsidian/Signal already on ALT+2/ALT+7) or that
-- aren't used (Music, Music TUI, Editor, Omawrite).
hl.unbind("SUPER + SHIFT + O") -- Obsidian focus-or-launch, duplicates ALT+2 scratchpad
hl.unbind("SUPER + SHIFT + G") -- Signal focus-or-launch, duplicates ALT+7 scratchpad
hl.unbind("SUPER + SHIFT + SLASH") -- Passwords, duplicates ALT+9 Bitwarden scratchpad
hl.unbind("SUPER + SHIFT + M") -- Music
hl.unbind("SUPER + SHIFT + ALT + M") -- Music TUI
hl.unbind("SUPER + SHIFT + N") -- Editor
hl.unbind("SUPER + SHIFT + W") -- Omawrite
hl.unbind("SUPER + ALT + F") -- Full width (maximize)
hl.unbind("SUPER + CTRL + F") -- Tiled full screen
hl.unbind("SUPER + BACKSPACE") -- Toggle window transparency
hl.unbind("SUPER + CTRL + BACKSPACE") -- Toggle single-window square aspect
hl.unbind("SUPER + ALT + Home") -- Save window width
hl.unbind("SUPER + Home") -- Restore window width
hl.unbind("SUPER + mouse_down") -- Scroll active workspace forward
hl.unbind("SUPER + mouse_up") -- Scroll active workspace backward
hl.unbind("SUPER + SLASH") -- Monitor scaling up
hl.unbind("SUPER + ALT + SLASH") -- Monitor scaling down
hl.unbind("ALT + PRINT") -- Screenrecording
hl.unbind("SUPER + CTRL + PRINT") -- Extract text (OCR) from screenshot
hl.unbind("SUPER + CTRL + S") -- Share
hl.unbind("SHIFT + ALT + D") -- Download video from web app
hl.unbind("SHIFT + ALT + L") -- Copy URL from web app
hl.unbind("SUPER + CTRL + PERIOD") -- Transcode
hl.unbind("SUPER + CTRL + O") -- Toggle menu
hl.unbind("SUPER + SHIFT + CTRL + SPACE") -- Theme menu
hl.unbind("SUPER + ALT + BRACKETLEFT") -- Make webcam overlay smaller
hl.unbind("SUPER + ALT + BRACKETRIGHT") -- Make webcam overlay larger

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
--
-- omarchy-snip replaces omarchy-capture-screenshot on the main key. The stock
-- picker paints a hyprpicker freeze over all three outputs and slurp repaints
-- its full surface in software on every mouse move, which on this ~20.7 Mpx
-- canvas makes the drag stutter. omarchy-snip drops the freeze and lowers the
-- PNG compression level. The stock tool stays on SUPER+SHIFT+ALT+S for when
-- the freeze is actually wanted - capturing an open menu, or a moving video.
hl.unbind("PRINT")
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-snip")
o.bind("SUPER + SHIFT + ALT + S", "Screenshot (frozen screen)", "omarchy-capture-screenshot")

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
