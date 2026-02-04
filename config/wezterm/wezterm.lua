-- config: https://wezfurlong.org/wezterm/config/lua/config/index.html
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Get window width in columns
local function get_max_cols(window)
    local tab = window:active_tab()
    return tab:get_size().cols
end

-- Update width on window load/resize
wezterm.on('window-config-reloaded', function(window)
    wezterm.GLOBAL.cols = get_max_cols(window)
end)

wezterm.on('window-resized', function(window, pane)
    wezterm.GLOBAL.cols = get_max_cols(window)
end)

-- Calculate padding to distribute tabs evenly
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    local full_title = '[' .. tab.tab_index + 1 .. '] ' .. title
    local pad_length = (wezterm.GLOBAL.cols // #tabs - #full_title) // 2
    if pad_length * 2 + #full_title > max_width then
        pad_length = (max_width - #full_title) // 2
    end
    return string.rep(' ', pad_length) .. full_title .. string.rep(' ', pad_length)
end)

wezterm.on(
    "update-right-status",
    function(window)
        local date = wezterm.strftime("%Y-%m-%d %H:%M:%S ")
        window:set_right_status(
            wezterm.format(
                {
                    { Text = date }
                }
            )
        )
    end
)

-- Key bindings
config.keys = {
    -- clean the screen
    {
        key = 'k',
        mods = 'SUPER',
        action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
    }
}

-- Font settings
config.font = wezterm.font_with_fallback({
    { family = "Maple Mono Normal NF CN",      weight = "Medium", italic = false },
    { family = "JetBrainsMono Nerd Font Mono", weight = "Medium", italic = false },
    { family = "Hack Nerd Font",               weight = "Medium", italic = false },
})
config.font_size = 16
config.line_height = 1.2
config.cell_width = 1
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Color scheme can be found here: https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/wezterm
config.color_scheme = "nord"

-- Cursor settings
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 400
config.force_reverse_video_cursor = false

-- Tab bar settings (must use retro style for centered tabs)
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 999
config.show_new_tab_button_in_tab_bar = false

-- Window settings
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.window_decorations = "TITLE | RESIZE"
config.native_macos_fullscreen_mode = false
config.window_background_opacity = 1.0

-- Input settings
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.use_ime = true

-- Terminal settings
-- term = "wezterm",
-- set term to wezterm will break the nvim titlestring option, see https://github.com/wez/wezterm/issues/2112
config.term = "xterm-256color"
config.automatically_reload_config = false

return config
