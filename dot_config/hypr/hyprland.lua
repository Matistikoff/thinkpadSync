-- Hyprland loads this file when it is started without a config, and it prefers
-- it over hyprland.conf. HyDE loads it too, last, as the override layer below.
-- The block keeps the two apart: hyde.lua sets `hyde` on its first line, so it
-- runs only when this file is the entry point and HyDE has not been loaded.
-- Removing it leaves a session with a cursor and nothing else.
if not hyde then
	local share = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
	local entry = share .. "/hypr/hyde.lua"
	local handle = io.open(entry, "r")
	if not handle then
		error("HyDE is not installed at " .. entry .. ". Run install.sh -r, or point Hyprland at your own config.")
	end
	handle:close()
	dofile(entry)
end

-- Your Hyprland configuration. HyDE never overwrites this file.
-- Follow Firefox activation requests when opening links from other apps.
hl.window_rule({
	name = "firefox-focus-on-activate",
	match = { class = "^[Ff]irefox.*$" },
	focus_on_activate = true,
})

--
-- It loads after HyDE's own binds, so settings here take precedence. Replacing
-- a bind needs more than that: see below. HyDE's defaults live in
-- ~/.local/share/hypr/lua/ and are overwritten on every update, so edits there
-- do not survive.
--
-- Adding a keybind:
--
--     hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(hyde.sh.gamelauncher()), {
--         description = "[Utilities] game launcher",
--     })
--
-- Replacing one of HyDE's: bind the same combination again and yours takes
-- over, but copy its flags across as well. A bind counts as the same one only
-- when its flags match, and `description` is not a flag — miss one and both
-- binds stay live on that combination. Copy the whole options table from
-- ~/.local/share/hypr/lua/key_binds.lua and change only what you need:
--
--     hl.bind("F9", hl.dsp.exec_cmd(hyde.sh.volumecontrol("-o", "m")), {
--         locked = true,
--         description = "[Hardware Controls|Audio] un/mute output",
--     })
--
-- Press SUPER + / to see what is actually loaded, your own binds included.
-- The full reference is KEYBINDINGS.md in the HyDE repository.
--
-- Other Lua files next to this one can be pulled in with require("name").

-- Faster key repeat when holding Backspace or other keys.
hl.config({
	input = {
		kb_options = "caps:escape",
		repeat_rate = 50,
		repeat_delay = 250,
	},
})

-- Open the terminal with Mod + Enter instead of Mod + T.
hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + T"))
hl.bind(hyde.config.modifiers.main .. " + Return", hl.dsp.exec_cmd("kitty --class tiled-terminal --start-as normal"), {
	description = "[Launcher|Apps] terminal emulator",
})

-- Swap the browser and floating-window shortcuts.
hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + W"))
hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + B"))
hl.bind(hyde.config.modifiers.main .. " + W", hl.dsp.exec_cmd(hyde.config.app.browser), {
	description = "[Launcher|Apps] browser",
})
hl.bind(hyde.config.modifiers.main .. " + B", hl.dsp.window.float({action = "toggle"}), {
	description = "[Window Management] toggle float true",
})

-- Toggle full fullscreen instead of pinning the focused window.
hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + SHIFT + F"))
hl.bind(hyde.config.modifiers.main .. " + SHIFT + F", function()
	local window = hl.get_active_window()
	if not window then return end
	local state = tonumber(window.fullscreen) == 2 and 0 or 2
	hl.dispatch(hl.dsp.window.fullscreen_state({internal = state, client = state, window = window}))
end, {
	description = "[Window Management] toggle full fullscreen",
})

-- Show/hide the floating terminal while keeping its shell running.
hl.bind(hyde.config.modifiers.main .. " + SHIFT + Return", hl.dsp.exec_cmd("hyde-shell pypr toggle console"), {
	description = "[Launcher|Apps] toggle dropdown terminal",
})

-- Show/hide Spotify without stopping playback.


hl.window_rule({
	name = "spotify-dropdown-floating",
	match = { class = "^Spotify$" },
	float = true,
})

hl.bind(hyde.config.modifiers.main .. " + M", hl.dsp.exec_cmd("python3 $HOME/.local/bin/toggle-desktop-panel spotify"), {
	description = "[Launcher|Apps] toggle Spotify dropdown",
})

-- Select a region to record; press again to stop and save to ~/Videos.
hl.bind(hyde.config.modifiers.main .. " + CTRL + R", hl.dsp.exec_cmd("$HOME/.local/bin/toggle-screen-recording"), {
	description = "[Utilities|Screen Capture] start/stop screen recording",
})

-- Show/hide Waybar with Mod + Shift + B.
hl.bind(hyde.config.modifiers.main .. " + SHIFT + B", hl.dsp.exec_cmd("python3 $HOME/.local/bin/toggle-desktop-panel waybar"), {
	description = "[Window Management] toggle waybar visibility",
})

-- Open the logout menu with Mod + Shift + Backspace.
hl.unbind(hyde.binds.normalize("CTRL + ALT + DELETE"))
hl.bind(hyde.config.modifiers.main .. " + SHIFT + BackSpace", hl.dsp.exec_cmd(hyde.sh.session.logout.launcher()), {
	description = "[Window Management] logout menu",
})

-- Tile new windows beside existing windows instead of filling the workspace.
hl.config({
	general = { layout = "dwindle" },
	dwindle = {
		force_split = 2,
		preserve_split = true,
	},
})

-- Keep regular terminals tiled, independently of dropdown and dialog rules.
hl.window_rule({
	name = "regular-terminal-tiled",
	match = { class = "^tiled-terminal$" },
	float = false,
	suppress_event = "maximize fullscreen",
})

-- Move windows with Shift without following; Alt moves and follows.
for i = 1, 10 do
	local key = (i == 10) and 0 or i
	hl.bind(hyde.config.modifiers.main .. " + SHIFT + " .. key, hl.dsp.window.move({workspace = i, follow = false}), {
		description = "[Workspaces|Move window (Don't follow)] move focused window to workspace " .. i,
	})
	hl.bind(hyde.config.modifiers.main .. " + ALT + " .. key, hl.dsp.window.move({workspace = i}), {
		description = "[Workspaces|Move window to workspace] move focused window to workspace " .. i,
	})
end

-- Show/hide Ferdium with numpad 1, with either Num Lock state.
hl.window_rule({
    name = "ferdium-dropdown-floating",
    match = { class = "^[Ff]erdium$" },
    float = true,
})
for _, key in ipairs({"KP_1", "KP_End"}) do
    hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + " .. key))
    hl.bind(hyde.config.modifiers.main .. " + " .. key, hl.dsp.exec_cmd("hyde-shell pypr toggle ferdium"), {
        description = "[Launcher|Apps] toggle Ferdium dropdown",
    })
end

-- Show/hide Teams with numpad 4, with either Num Lock state.
hl.window_rule({
    name = "teams-dropdown-floating",
    match = { class = "^[Tt]eams-for-linux$" },
    float = true,
})
for _, key in ipairs({"KP_4", "KP_Left"}) do
    hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + " .. key))
    hl.bind(hyde.config.modifiers.main .. " + " .. key, hl.dsp.exec_cmd("hyde-shell pypr toggle teams"), {
        description = "[Launcher|Apps] toggle Microsoft Teams dropdown",
    })
end

-- A second close request accepts Kitty's visible OS-window confirmation.
hl.bind(hyde.config.modifiers.main .. " + Q", function()
    local window = hl.get_active_window()
    if not window then return end
    if window.title == "Close OS window" and window.pid then
        local process = io.open("/proc/" .. tostring(window.pid) .. "/comm", "r")
        if process then
            local name = process:read("*l")
            process:close()
            if name == "kitty" then
                hl.dispatch(hl.dsp.send_shortcut({mods = "", key = "y", window = window}))
                return
            end
        end
    end
    hl.dispatch(hl.dsp.window.close({window = window}))
end, {
    description = "[Window Management] close focused window",
})

-- Personal wallpaper folder; scan it again each time the chooser opens.
for _, key in ipairs({"Q", "W"}) do
    hl.unbind(hyde.binds.normalize(hyde.config.modifiers.main .. " + SHIFT + " .. key))
    hl.bind(hyde.config.modifiers.main .. " + SHIFT + " .. key, hl.dsp.exec_cmd("$HOME/.local/bin/wallpaper --select"), {
        description = "[Theming and Wallpaper] select from Pictures/wallpaper",
    })
end

-- Výnimky tohto počítača; tento súbor nie je v Gite.
local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local local_config = config_home .. "/hypr/local.lua"
local local_file = io.open(local_config, "r")
if local_file then
    local_file:close()
    dofile(local_config)
end
