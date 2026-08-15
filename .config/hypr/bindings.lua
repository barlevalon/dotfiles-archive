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

local function close_active_window_except_schedule_i()
  local window = hl.get_active_window()
  if window and (window.class == "steam_app_3164500" or window.title == "Schedule I") then
    return
  end

  hl.dispatch(hl.dsp.window.close())
end

-- Replace conflicting Omarchy defaults.
hl.unbind("SUPER + ALT + RETURN")
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + ALT + B")
hl.unbind("SUPER + SHIFT + G")
hl.unbind("SUPER + SHIFT + W")
hl.unbind("SUPER + SHIFT + SLASH")
hl.unbind("SUPER + SHIFT + C")
hl.unbind("SUPER + SHIFT + E")
hl.unbind("SUPER + SHIFT + Y")
hl.unbind("SUPER + SHIFT + CTRL + G")
hl.unbind("SUPER + SHIFT + X")
hl.unbind("SUPER + SHIFT + ALT + X")
hl.unbind("SUPER + W")

o.bind("SUPER + ALT + RETURN", "Tmux", "uwsm-app -- xdg-terminal-exec --dir=\"$(omarchy-cmd-terminal-cwd)\" sesh connect scratch")
o.bind("SUPER + SHIFT + RETURN", "Browser", "uwsm-app -- vivaldi-stable --new-window about:blank")
o.bind("SUPER + SHIFT + A", "Base workspaces", "~/.config/hypr/scripts/setup-base-workspaces")
o.bind("SUPER + SHIFT + F", "File manager", { tui = "yazi" })
o.bind("SUPER + SHIFT + B", "Browser", "uwsm-app -- vivaldi-stable --new-window about:blank")
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", "omarchy-launch-browser --private")
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })
o.bind("SUPER + SHIFT + G", "WhatsApp", "omarchy-launch-or-focus-webapp whatsapp 'https://web.whatsapp.com/'")
o.bind("SUPER + SHIFT + W", "Toggle webcam flip", "~/.config/hypr/scripts/webcam-flip-toggle")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop" })
o.bind("SUPER + SHIFT + C", "Calendar", "omarchy-launch-or-focus-webapp vivaldi-calendar 'https://app.fastmail.com/calendar'")
o.bind("SUPER + SHIFT + E", "Email", "omarchy-launch-or-focus-webapp vivaldi-mail 'https://mail.hearter.io'")
o.bind("SUPER + SHIFT + Y", "YouTube", "omarchy-launch-or-focus-webapp vivaldi-youtube 'https://youtube.com/'")
o.bind("SUPER + SHIFT + CTRL + G", "Google Messages", "omarchy-launch-or-focus-webapp vivaldi-messages 'https://messages.google.com/web/conversations'")
o.bind("SUPER + SHIFT + X", "X", "omarchy-launch-or-focus-webapp vivaldi-x 'https://x.com/'")
o.bind("SUPER + SHIFT + ALT + X", "X Post", "omarchy-launch-or-focus-webapp vivaldi-x 'https://x.com/compose/post'")
o.bind("SUPER + W", "Close window except Schedule I", close_active_window_except_schedule_i)
o.bind("SUPER + SHIFT + CTRL + ALT + S", "Swap split", hl.dsp.layout("swapsplit"))
