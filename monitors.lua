-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Fixed desk layout, left to right: laptop panel, Dell, Samsung.
-- Named by connector (stable) instead of "auto" (order-of-detection, unstable).
-- Positions are computed from each panel's native size / the shared scale,
-- so the layout stays correct even after SUPER+/ changes omarchy_monitor_scale.
-- The laptop sits lower than the Dell (desk height vs monitor stand), so its
-- bottom edge is aligned with the Dell's bottom edge, not top-aligned.
local laptop_w, laptop_h = 1920, 1080
local dell_w, dell_h = 3840, 2160
local dp5_y = 0
local dp1_y = 0
local dell_logical_h = math.floor(dell_h / omarchy_monitor_scale)
local laptop_logical_h = math.floor(laptop_h / omarchy_monitor_scale)
local edp1_y = dell_logical_h - laptop_logical_h
local edp1_x = 0
local dp5_x = math.floor(laptop_w / omarchy_monitor_scale)
local dp1_x = dp5_x + math.floor(dell_w / omarchy_monitor_scale)

hl.monitor({ output = "eDP-1", mode = "preferred", position = edp1_x .. "x" .. edp1_y, scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-5", mode = "preferred", position = dp5_x .. "x" .. dp5_y, scale = omarchy_monitor_scale })
hl.monitor({ output = "DP-1", mode = "preferred", position = dp1_x .. "x" .. dp1_y, scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
