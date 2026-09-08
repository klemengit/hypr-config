# hypr config

Personal [Hyprland](https://hypr.land) configuration for Omarchy, living in
`~/.config/hypr`.

Omarchy seeds this directory once from `/usr/share/omarchy/config/hypr` and then
leaves it alone, so everything here is mine to edit. `hyprland.lua` is the entry
point: it bootstraps Omarchy's defaults, loads them, then loads the override
files in order.

| File             | Holds                                              |
| ---------------- | -------------------------------------------------- |
| `hyprland.lua`   | Entry point — loads Omarchy defaults, then the rest |
| `monitors.lua`   | Three-monitor desk layout, per-monitor scaling      |
| `input.lua`      | Touchpad, focus-follows-mouse, keyboard layout      |
| `bindings.lua`   | Keybinding overrides (below)                        |
| `looknfeel.lua`  | Appearance overrides (all defaults for now)         |
| `autostart.lua`  | Extra startup processes (empty for now)             |
| `hyprsunset.conf`, `xdph.conf` | Night light, screen sharing          |

Because Omarchy's own defaults stay in `/usr/share/omarchy`, package updates can
improve them without touching anything here. To see the full binding list
including defaults:

```sh
omarchy menu keybindings --print
```

## Keybindings

Only the ones this config adds or changes. Everything else is an Omarchy
default.

### Apps — focus or launch

Press once to focus the app if it's running, launch it if it isn't. No
duplicate windows.

| Keys                                    | App                           |
| --------------------------------------- | ----------------------------- |
| `Alt+1`, `Super+Shift+Return`, `Super+Shift+B` | Browser                |
| `Alt+3`                                 | Nautilus                      |
| `Alt+4`, `Super+Alt+Return`             | Herdr (local)                 |
| `Alt+5`                                 | Herdr on `linux-turbo`        |

`Alt+5` gets its own window and app-id rather than a pane inside the local
herdr — herdr refuses to nest by default, and both sides would fight over the
`Ctrl+Space` prefix.

### Apps — scratchpad toggle

Apps checked occasionally, not worth a permanent workspace slot. Each lives in
its own named special workspace: one key shows it from anywhere, the same key
hides it, and the app keeps running in between. First press launches it.

| Keys    | App              |
| ------- | ---------------- |
| `Alt+2` | Obsidian         |
| `Alt+7` | Signal           |
| `Alt+8` | Activity (btop)  |
| `Alt+9` | Bitwarden        |

### Moving things between monitors

`hjkl` directions, matching the Ferris Sweep layout. Monitors are laid out
left-to-right only, so the up/down binds are dead until a vertical monitor
shows up.

| Keys                | Action                              |
| ------------------- | ----------------------------------- |
| `Super+H` / `Super+L` | Move active **window** to left/right monitor |
| `Super+Shift+H` / `Super+Shift+L` | Move whole **workspace** to left/right monitor |

Together with Omarchy's default `Super+Shift+1..9` ("move window to workspace
N") that covers the arranging workflow: put the window in the workspace slot you
want, then put that workspace on the screen you want.

### Other

| Keys            | Action     |
| --------------- | ---------- |
| `Super+Shift+S` | Screenshot |

Rebound from `Print`, which isn't mapped anywhere on the Ferris Sweep.

### Removed defaults

`bindings.lua` unbinds a batch of Omarchy defaults: the ones the scratchpads
above already cover (Obsidian, Signal, Passwords), unused app binds (Music,
Editor, Omawrite), assorted window/monitor tweaks, and every preinstalled webapp
hotkey (ChatGPT, Grok, Calendar, Email, YouTube, WhatsApp, Google
Messages/Photos/Maps, X). The webapps still have real `.desktop` entries, so
`Super+Space` finds them by name — only the dedicated hotkeys are gone.

## Monitors

Fixed desk layout, left to right: laptop panel, Dell, Samsung. Outputs are named
by connector rather than `auto`, since detection order isn't stable. Positions
are computed from each panel's native size divided by its own scale, so the
layout survives the per-monitor scales diverging. The laptop sits lower than the
Dell on the desk, so the two are bottom-edge aligned rather than top-aligned.

## Install

```sh
git clone git@github.com:klemengit/hypr-config.git ~/.config/hypr
```

Move any existing `~/.config/hypr` aside first.
