local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = "Catppuccin Mocha"
-- Font configuration with fallbacks
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMonoNL Nerd Font" },
	{ family = "JetBrainsMono Nerd Font" },
	{ family = "Hack Nerd Font" },
	{ family = "Monaco" },
	{ family = "Menlo" },
})
config.font_size = 19.0

config.hide_mouse_cursor_when_typing = true

config.window_background_opacity = 0.75
config.macos_window_background_blur = 20

config.use_fancy_tab_bar = true
config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bb"),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"),
	},
}

return config
