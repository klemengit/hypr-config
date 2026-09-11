-- Full hl.monitor syntax (modes, position, transform): https://wiki.hypr.land/Configuring/Basics/Monitors/

local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Every monitor is matched by EDID description, not connector name.
--
-- Connector names (DP-5, DP-6, HDMI-A-1, ...) are NOT stable for USB-C /
-- DisplayPort-alt-mode outputs: the same physical Dell has come up as DP-5,
-- DP-6 and HDMI-A-1 on the same CRTC across replugs and dock re-enumeration.
-- When the name shifts, a connector-pinned rule stops matching, the monitor
-- falls back to auto placement, and the layout gets a dead gap in it.
-- The description (make + model + serial) survives all of that.
--
-- Positions, scales and rotations are saved by the hyprlayout TUI
-- (~/Work/hyprlayout) to monitor-layout.lua, keyed by description - arrange
-- monitors with `hyprlayout`, not by editing here.
local saved_ok, saved = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/monitor-layout.lua")
if not saved_ok or type(saved) ~= "table" then
  saved = {}
end

for description, p in pairs(saved) do
  hl.monitor({
    output = "desc:" .. description,
    mode = "preferred",
    position = (p.x and p.y) and (p.x .. "x" .. p.y) or "auto",
    scale = p.scale or 1.25,
    transform = p.transform,
  })
end
