-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Personal overrides that must win over dynamic toggles.
hl.config({
  general = {
    border_size = 1,
    col = {
      inactive_border = "rgba(00000000)",
    },
  },
  layout = {
    single_window_aspect_ratio = { 1, 0.75 },
  },
})

-- Personal window rules.
o.window({ tag = "floating-window" }, { size = { 1600, 1000 } })
o.window({ class = "^org\\.quickshell$", title = "^Omarchy Spotify$" }, {
  float = true,
  center = true,
  size = { 1600, 1000 },
})
o.window({ class = "steam", title = "Steam" }, { tile = true })
o.window("^steam_app_[0-9]+$", { render_unfocused = true })
o.window("^steam_app_359320$", {
  float = true,
  center = true,
  tag = "-default-opacity",
  opacity = "1 1",
  idle_inhibit = "fullscreen",
})
o.window("^vivaldi-app\\.plex\\.tv__-Default$", {
  tag = "-default-opacity",
  opacity = "1 override 1 override 1 override",
})

-- Keep video and photo-editing windows fully opaque, focused or not.
o.window({ tag = "pip" }, {
  tag = "-default-opacity",
  opacity = "1 override 1 override 1 override",
})
o.window({ title = "^(.*YouTube.*|Plex.*|▶ .*)$" }, {
  tag = "-default-opacity",
  opacity = "1 override 1 override 1 override",
})
o.window("^(zoom|vlc|mpv|org\\.kde\\.kdenlive|com\\.obsproject\\.Studio|org\\.darktable\\.darktable)$", {
  tag = "-default-opacity",
  opacity = "1 override 1 override 1 override",
})
