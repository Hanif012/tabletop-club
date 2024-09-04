# tabletop-club
# Copyright (c) 2020-2024 Benjamin 'drwhut' Beddows.
# Copyright (c) 2021-2024 Tabletop Club contributors (see game/CREDITS.tres).
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends Node

## Stores configurable properties for the game, accessed by the options menu.
##
## NOTE: All floating-point properties are standardised to be between either 0
## and 1, or 0.01 and 1, depending on if a value of 0 makes sense for that
## property. It is up to other sections of code to determine how to transform
## that number.
## TODO: Test this class once it is complete (include v0.1.x file in testing).


## Fired when the current configuration is being applied to the entire game.
signal applying_settings()


## How often the game should create an autosave.
enum {
	AUTOSAVE_NEVER,
	AUTOSAVE_30_SEC,
	AUTOSAVE_1_MIN,
	AUTOSAVE_5_MIN,
	AUTOSAVE_10_MIN,
	AUTOSAVE_30_MIN,
	AUTOSAVE_MAX ## Used for validation only.
}

## The size of the font in the chat box.
enum {
	FONT_SIZE_SMALL,
	FONT_SIZE_MEDIUM,
	FONT_SIZE_LARGE,
	FONT_SIZE_MAX ## Used for validation only.
}

## The mode in which the game window is displayed.
enum {
	MODE_WINDOWED,
	MODE_BORDERLESS_FULLSCREEN,
	MODE_FULLSCREEN,
	MODE_MAX ## Used for validation only.
}

## How detailed shadows should be.
enum {
	SHADOW_DETAIL_LOW,
	SHADOW_DETAIL_MEDIUM,
	SHADOW_DETAIL_HIGH,
	SHADOW_DETAIL_VERY_HIGH,
	SHADOW_DETAIL_MAX ## Used for validation only.
}

## What method should be used for anti-aliasing.
enum {
	AA_OFF,
	AA_FXAA,
	AA_MSAA,
	AA_MAX ## Used for validation only.
}

## How many samples should be performed during MSAA.
enum {
	MSAA_2X,
	MSAA_4X,
	MSAA_8X,
	MSAA_16X,
	MSAA_MAX ## Used for validation only.
}

## How detailed ambient occlusion should be.
enum {
	SSAO_NONE,
	SSAO_LOW,
	SSAO_MEDIUM,
	SSAO_HIGH,
	SSAO_MAX ## Used for validation only.
}

## How detailed the lighting from the skybox should be.
enum {
	RADIANCE_LOW,
	RADIANCE_MEDIUM,
	RADIANCE_HIGH,
	RADIANCE_VERY_HIGH,
	RADIANCE_ULTRA,
	RADIANCE_MAX ## Used for validation only.
}

## The quality of the depth-of-field effect.
enum {
	DOF_NONE,
	DOF_LOW,
	DOF_MEDIUM,
	DOF_HIGH,
	DOF_MAX ## Used for validation only.
}


## The path to the file containing these saved properties.
const CONFIG_FILE_PATH := "user://options.cfg"


## The volume of the master audio bus.
## NOTE: This value will need to be converted into dB in order to be useable by
## the [AudioServer].
var audio_master_volume := 0.5 setget set_audio_master_volume

## The volume of the music audio bus.
## NOTE: This value will need to be converted into dB in order to be useable by
## the [AudioServer].
var audio_music_volume := 1.0 setget set_audio_music_volume

## The volume of the sounds audio bus.
## NOTE: This value will need to be converted into dB in order to be useable by
## the [AudioServer].
var audio_sounds_volume := 1.0 setget set_audio_sounds_volume

## The volume of the effects audio bus.
## NOTE: This value will need to be converted into dB in order to be useable by
## the [AudioServer].
var audio_effects_volume := 1.0 setget set_audio_effects_volume


## The sensitivity scalar when rotating the camera horizontally.
var control_horizontal_sensitivity := 0.05 \
	setget set_control_horizontal_sensitivity

## The sensitivty scalar when rotating the camera vertically.
var control_vertical_sensitivity := 0.05 \
	setget set_control_vertical_sensitivity

## Determines if the horizontal rotation of the camera should be inverted.
var control_horizontal_invert := false

## Determines if the vertical rotation of the camera should be inverted.
var control_vertical_invert := false

## The movement speed of the game camera.
var control_camera_movement_speed := 0.25 \
	setget set_control_camera_movement_speed

## Determines if holding down the left mouse button moves the camera.
## TODO: Implement this setting.
var control_left_mouse_button_moves_camera := false

## The sensitivity scalar when zooming the camera in and out.
var control_zoom_sensitivity := 0.25 setget set_control_zoom_sensitivity

## Determines if the zoom direction of the camera should be inverted.
var control_zoom_invert := false

## The sensitivity scalar when lifting pieces up and down.
## TODO: Implement this setting.
var control_piece_lift_sensitivity := 0.15 \
	setget set_control_piece_lift_sensitivity

## Determines if the direction that pieces are lifted should be inverted.
## TODO: Implement this setting.
var control_piece_lift_invert := false

## Determines if the direction pieces are rotated should be inverted.
## TODO: Implement this setting.
var control_piece_rotation_invert := false

## Determines if cards should be shown in the UI when hovering over them in hand.
## TODO: Implement this setting.
var control_hand_preview_enabled := true

## How long the mouse need to hover over a card before the preview is displayed.
## TODO: Implement this setting.
var control_hand_preview_delay := 0.5 setget set_control_hand_preview_delay

## How big the preview UI should be when hovering over cards in hand.
## TODO: Implement this setting.
var control_hand_preview_size := 0.5 setget set_control_hand_preview_size

## Determines if the control hints shown in the UI should be hidden.
## TODO: Implement this setting.
var control_hide_hints := false


## The locale code of the language the game is currently using. If empty, the
## system's language is used if it is supported, otherwise the game will default
## to English.
var general_language := "" setget set_general_language

## How often the game should create autosaves, using the [code]AUTOSAVE_*[/code]
## values.
## TODO: Implement this setting.
var general_autosave_interval := AUTOSAVE_5_MIN \
	setget set_general_autosave_interval

## The maximum number of autosave files that should be made.
## TODO: Implement this setting.
var general_autosave_file_count := 10 setget set_general_autosave_file_count

## Determines if the splash screen should be skipped at the start of the game.
var general_skip_splash_screen := false

## Determines if system warnings should be shown in the chat box.
var general_show_warnings := true

## Determines if system errors should be shown in the chat box.
var general_show_errors := true


## The name given to this client's player in multiplayer.
## TODO: Implement this setting.
var multiplayer_name := "Player" setget set_multiplayer_name

## The self-assigned colour given to this client's player
## TODO: Implement this setting.
var multiplayer_color := Color.white setget set_multiplayer_color

## The size of the font in the chat window.
## TODO: Implement this setting.
var multiplayer_chat_font_size := FONT_SIZE_MEDIUM \
	setget set_multiplayer_chat_font_size

## Determines if other player's cursors should be hidden in multiplayer.
## TODO: Implement this setting.
var multiplayer_hide_cursors := false

## Determines if profanity should be filtered in the chat window.
## TODO: Implement this setting.
var multiplayer_censor_profanity := true


## Determines how the game window should be displayed.
var video_window_mode := MODE_WINDOWED setget set_video_window_mode

## Determines the field of view of the camera in degrees.
var video_fov := 70.0 setget set_video_fov

## Determines if VSync should be enabled or not.
var video_vsync := true

## TODO: Add setting for custom FPS limit when using Godot 4.2+.

## Determines how much the UI should be scaled from it's default size.
var video_ui_scale := 1.0 setget set_video_ui_scale

## Determines how detailed shadows are.
var video_shadow_detail := SHADOW_DETAIL_MEDIUM setget set_video_shadow_detail

## Determines what method should be used for anti-aliasing.
var video_aa_method := AA_FXAA setget set_video_aa_method

## Determines how many samples should be used when using MSAA.
var video_msaa_samples := MSAA_4X setget set_video_msaa_samples

## Determines the quality of SSAO.
var video_ssao := SSAO_NONE setget set_video_ssao

## TODO: Add a setting for sub-surface scattering once there is sufficient
## reason to do so. Right now, it is not possible for the camera to be pointed
## towards a light that is behind an object - maybe once we add the abiity to
## let players place their own lights, this might become possible.

## TODO: Add a setting for reflections once the game is using Godot 4.x, where
## we can take advantage of GI. I've tried screen space reflections in Godot 3,
## but they don't work as well as I would like.

## Determines how detailed the lighting is from the skybox.
## NOTE: It's worth pointing out that "Very High" and "Ultra" settings can
## potentially crash the game on older hardware, but I've made the decision to
## keep those settings as a means of future-proofing if we ever choose to
## include higher-quality skyboxes.
var video_skybox_radiance_detail := RADIANCE_LOW \
	setget set_video_skybox_radiance_detail

## Determines the quality of the depth-of-field effect.
var video_depth_of_field := DOF_NONE setget set_video_depth_of_field

## Determines how much the background is blurred when using depth of field.
var video_depth_of_field_amount := 0.5 setget set_video_depth_of_field_amount

## Determines the distance to the background when using depth of field.
var video_depth_of_field_distance := 0.5 setget set_video_depth_of_field_distance

## Determines if the table paint texture is filtered or not.
var video_table_paint_filtering := true

## Determines how bright the game is.
var video_brightness := 1.0 setget set_video_brightness

## Determines how much contrast the game has.
var video_contrast := 1.0 setget set_video_contrast

## Determines how much saturation the game has.
var video_saturation := 1.0 setget set_video_saturation


## A flag which is set to [code]true[/code] if the configuration file uses the
## old key binding system from v0.1.x.
##
## This flag is set during [method load_from_file], and is set to
## [code]false[/code] during [method save_to_file]. This flag cannot be set
## manually from the outside.
##
## v0.1.x: All bindings are stored, even if they are the same as the default.
## v0.2.0+: Only bindings that differ from the default are stored. That way, if
## the default binding changes in a given version, then most players will use
## the new default, which will prevent both potential confusion between players,
## and the possibility of bindings overlapping each other (although this can't
## be helped if bindings are overwritten).
var flag_using_old_binding_system := false \
		setget set_flag_using_old_binding_system


# The list of actions whose bindings can be configured by the player.
var _configurable_actions := PoolStringArray()


func _init():
	var all_actions := InputMap.get_actions()
	for element in all_actions:
		var action: String = element
		if not action.begins_with("ui"):
			_configurable_actions.push_back(action)


## Load the previously saved configuration from the disk.
func load_from_file() -> void:
	var dir := Directory.new()
	if not dir.file_exists(CONFIG_FILE_PATH):
		return
	
	print("GameConfig: Loading settings from '%s' ..." % CONFIG_FILE_PATH)
	
	var config_file := AdvancedConfigFile.new()
	var err := config_file.load(CONFIG_FILE_PATH)
	if err != OK:
		push_error("Failed to load game settings from '%s' (error: %d)" % [
			CONFIG_FILE_PATH, err])
		return
	
	set_audio_master_volume(config_file.get_value_strict("audio",
		"master_volume", audio_master_volume))
	set_audio_music_volume(config_file.get_value_strict("audio",
		"music_volume", audio_music_volume))
	set_audio_sounds_volume(config_file.get_value_strict("audio",
		"sounds_volume", audio_sounds_volume))
	set_audio_effects_volume(config_file.get_value_strict("audio",
		"effects_volume", audio_effects_volume))
	
	set_control_horizontal_sensitivity(config_file.get_value_strict("controls",
		"mouse_horizontal_sensitivity", control_horizontal_sensitivity))
	set_control_vertical_sensitivity(config_file.get_value_strict("controls",
		"mouse_vertical_sensitivity", control_vertical_sensitivity))
	
	control_horizontal_invert = config_file.get_value_strict("controls",
		"mouse_horizontal_invert", control_horizontal_invert)
	control_vertical_invert = config_file.get_value_strict("controls",
		"mouse_vertical_invert", control_vertical_invert)
	
	set_control_camera_movement_speed(config_file.get_value_strict("controls",
		"camera_movement_speed", control_camera_movement_speed))
	control_left_mouse_button_moves_camera = config_file.get_value_strict("controls",
		"left_click_to_move", control_left_mouse_button_moves_camera)
	
	set_control_zoom_sensitivity(config_file.get_value_strict("controls",
		"zoom_sensitivity", control_zoom_sensitivity))
	control_zoom_invert = config_file.get_value("controls",
		"zoom_invert", control_zoom_invert)
	
	set_control_piece_lift_sensitivity(config_file.get_value_strict("controls",
		"piece_lift_sensitivity", control_piece_lift_sensitivity))
	control_piece_lift_invert = config_file.get_value_strict("controls",
		"piece_lift_invert", control_piece_lift_invert)
	
	control_piece_rotation_invert = config_file.get_value_strict("controls",
		"piece_rotation_invert", control_piece_rotation_invert)
	
	control_hand_preview_enabled = config_file.get_value_strict("controls",
		"hand_preview_enabled", control_hand_preview_enabled)
	set_control_hand_preview_delay(config_file.get_value_strict("controls",
		"hand_preview_delay", control_hand_preview_delay))
	set_control_hand_preview_size(config_file.get_value_strict("controls",
		"hand_preview_size", control_hand_preview_size))
	
	control_hide_hints = config_file.get_value_strict("controls",
		"hide_control_hints", control_hide_hints)
	
	set_general_language(config_file.get_value_strict("general", "language",
		general_language))
	
	set_general_autosave_interval(config_file.get_value_strict("general",
		"autosave_interval", general_autosave_interval))
	
	# v0.1.x: Due to the way the options menu worked, the file count was
	# actually a float, so we need to account for this.
	var file_count_value = config_file.get_value("general",
		"autosave_file_count", general_autosave_file_count)
	match typeof(file_count_value):
		TYPE_INT:
			set_general_autosave_file_count(file_count_value)
		TYPE_REAL:
			set_general_autosave_file_count(int(file_count_value))
		_:
			push_error("Value of property 'autosave_file_count' in section 'general' is incorrect data type (expected: Integer, got: %s)" %
				SanityCheck.get_type_name(typeof(file_count_value)))
	
	general_skip_splash_screen = config_file.get_value_strict("general",
		"skip_splash_screen", general_skip_splash_screen)
	
	general_show_warnings = config_file.get_value_strict("general",
		"show_warnings", general_show_warnings)
	general_show_errors = config_file.get_value_strict("general",
		"show_errors", general_show_errors)
	
	set_multiplayer_name(config_file.get_value_strict("multiplayer",
		"name", multiplayer_name))
	set_multiplayer_color(config_file.get_value_strict("multiplayer",
		"color", multiplayer_color))
	
	set_multiplayer_chat_font_size(config_file.get_value_strict("multiplayer",
		"chat_font_size", multiplayer_chat_font_size))
	multiplayer_hide_cursors = config_file.get_value_strict("multiplayer",
		"hide_cursors", multiplayer_hide_cursors)
	multiplayer_censor_profanity = config_file.get_value_strict("multiplayer",
		"censor_profanity", multiplayer_censor_profanity)
	
	set_video_window_mode(config_file.get_value_strict("video", "window_mode",
		video_window_mode))
	set_video_fov(config_file.get_value_strict("video", "fov", video_fov))
	video_vsync = config_file.get_value_strict("video", "vsync", video_vsync)
	set_video_ui_scale(config_file.get_value_strict("video", "ui_scale",
		video_ui_scale))
	
	set_video_shadow_detail(config_file.get_value_strict("video",
		"shadow_detail", video_shadow_detail))
	
	# Backwards compatibility with v0.1.x!
	if config_file.has_section_key("video", "msaa"):
		var msaa_id: int = config_file.get_value_strict("video", "msaa", 0)
		match msaa_id:
			0:
				video_aa_method = AA_OFF
			1:
				video_aa_method = AA_MSAA
				video_msaa_samples = MSAA_2X
			2:
				video_aa_method = AA_MSAA
				video_msaa_samples = MSAA_4X
			3:
				video_aa_method = AA_MSAA
				video_msaa_samples = MSAA_8X
			4:
				video_aa_method = AA_MSAA
				video_msaa_samples = MSAA_16X
			_:
				push_error("Unknown value '%d' for setting 'video/msaa'" % msaa_id)
	else:
		set_video_aa_method(config_file.get_value_strict("video",
			"aa_method", video_aa_method))
		set_video_msaa_samples(config_file.get_value_strict("video",
			"msaa_samples", video_msaa_samples))
	
	set_video_ssao(config_file.get_value_strict("video",
		"ssao", video_ssao))
	set_video_skybox_radiance_detail(config_file.get_value_strict("video",
		"skybox_radiance_detail", video_skybox_radiance_detail))
	
	set_video_depth_of_field(config_file.get_value_strict("video",
		"depth_of_field", video_depth_of_field))
	set_video_depth_of_field_amount(config_file.get_value_strict("video",
		"depth_of_field_amount", video_depth_of_field_amount))
	set_video_depth_of_field_distance(config_file.get_value_strict("video",
		"depth_of_field_distance", video_depth_of_field_distance))
	
	video_table_paint_filtering = config_file.get_value_strict("video",
		"table_paint_filtering", video_table_paint_filtering)
	
	set_video_brightness(config_file.get_value_strict("video", "brightness",
		video_brightness))
	set_video_contrast(config_file.get_value_strict("video", "contrast",
		video_contrast))
	set_video_saturation(config_file.get_value_strict("video", "saturation",
		video_saturation))
	
	# The file may also contain keyboard or controller bindings - but only if
	# they differ from the default bindings.
	var binding_manager := BindingManager.new()
	
	# Backwards compatibility with v0.1.x!
	# NOTE: In v0.1.x, bindings were saved regardless of whether they were
	# changed from the default or not.
	flag_using_old_binding_system = config_file.has_section("key_bindings")
	
	var keyboard_0_section := "keyboard_bindings_0"
	if flag_using_old_binding_system:
		keyboard_0_section = "key_bindings"
	
	for action in _configurable_actions:
		var keyboard_bindings := []
		var controller_bindings := []
		var section_list := [ keyboard_0_section, "keyboard_bindings_1",
			"controller_bindings_0" ]
		
		# In v0.1.x, only the [,] and [.] keys were editable in the key bindings
		# menu, as the scroll wheel was permanently bound to zoom in / out.
		# Now that the scroll wheel bindings can be changed, if we were to go
		# ahead as normal only the [,] and [.] keys would end up bound to the
		# zoom actions, meaning the scroll wheel would not work.
		if flag_using_old_binding_system:
			if action == "game_zoom_in":
				var scroll_up := InputEventMouseButton.new()
				scroll_up.button_index = BUTTON_WHEEL_UP
				keyboard_bindings.push_back(scroll_up)
			elif action == "game_zoom_out":
				var scroll_down := InputEventMouseButton.new()
				scroll_down.button_index = BUTTON_WHEEL_DOWN
				keyboard_bindings.push_back(scroll_down)
		
		for element in section_list:
			var section: String = element
			
			var event: InputEvent = null
			if config_file.has_section_key(section, action):
				var value = config_file.get_value(section, action)
				
				if not value is InputEvent:
					push_error("Invalid value for '%s/%s' in '%s', not an InputEvent" % [
							section, action, CONFIG_FILE_PATH])
					continue
				
				# If we see an InputEventAction, it means the same thing as
				# "no binding". See save_to_file() for more details.
				if value is InputEventAction:
					continue
				
				event = value
			else:
				if section == "controller_bindings_0":
					event = binding_manager.get_controller_binding_default(
							action, 0)
				elif section == "keyboard_bindings_1":
					event = binding_manager.get_keyboard_binding_default(
							action, 1)
				else: # keyboard_bindings_0, key_bindings.
					event = binding_manager.get_keyboard_binding_default(
							action, 0)
			
			if event != null:
				if section == "controller_bindings_0":
					controller_bindings.push_back(event)
				else:
					keyboard_bindings.push_back(event)
		
		binding_manager.set_keyboard_bindings(action, keyboard_bindings)
		binding_manager.set_controller_bindings(action, controller_bindings)


## Save the current configuration to disk. Optional overrides can be given,
## where the keys are the names of the properties to override, and the values
## are the values that should be saved instead for those properties.
func save_to_file(overrides: Dictionary = {}) -> void:
	var config_file := ConfigFile.new()
	
	config_file.set_value("audio", "master_volume", audio_master_volume)
	config_file.set_value("audio", "music_volume", audio_music_volume)
	config_file.set_value("audio", "sounds_volume", audio_sounds_volume)
	config_file.set_value("audio", "effects_volume", audio_effects_volume)
	
	config_file.set_value("controls", "mouse_horizontal_sensitivity",
		control_horizontal_sensitivity)
	config_file.set_value("controls", "mouse_vertical_sensitivity",
		control_vertical_sensitivity)
	
	config_file.set_value("controls", "mouse_horizontal_invert",
		control_horizontal_invert)
	config_file.set_value("controls", "mouse_vertical_invert",
		control_vertical_invert)
	
	config_file.set_value("controls", "camera_movement_speed",
		control_camera_movement_speed)
	config_file.set_value("controls", "left_click_to_move",
		control_left_mouse_button_moves_camera)
	
	config_file.set_value("controls", "zoom_sensitivity",
		control_zoom_sensitivity)
	config_file.set_value("controls", "zoom_invert", control_zoom_invert)
	
	config_file.set_value("controls", "piece_lift_sensitivity",
		control_piece_lift_sensitivity)
	config_file.set_value("controls", "piece_lift_invert",
		control_piece_lift_invert)
	
	config_file.set_value("controls", "piece_rotation_invert",
		control_piece_rotation_invert)
	
	config_file.set_value("controls", "hand_preview_enabled",
		control_hand_preview_enabled)
	config_file.set_value("controls", "hand_preview_delay",
		control_hand_preview_delay)
	config_file.set_value("controls", "hand_preview_size",
		control_hand_preview_size)
	
	config_file.set_value("controls", "hide_control_hints", control_hide_hints)
	
	config_file.set_value("general", "language", general_language)
	
	config_file.set_value("general", "autosave_interval",
		general_autosave_interval)
	config_file.set_value("general", "autosave_file_count",
		general_autosave_file_count)
	
	config_file.set_value("general", "skip_splash_screen",
		general_skip_splash_screen)
	
	config_file.set_value("general", "show_warnings", general_show_warnings)
	config_file.set_value("general", "show_errors", general_show_errors)
	
	config_file.set_value("multiplayer", "name", multiplayer_name)
	config_file.set_value("multiplayer", "color", multiplayer_color)
	
	config_file.set_value("multiplayer", "chat_font_size",
		multiplayer_chat_font_size)
	config_file.set_value("multiplayer", "hide_cursors",
		multiplayer_hide_cursors)
	config_file.set_value("multiplayer", "censor_profanity",
		multiplayer_censor_profanity)
	
	config_file.set_value("video", "window_mode", video_window_mode)
	config_file.set_value("video", "fov", video_fov)
	config_file.set_value("video", "vsync", video_vsync)
	config_file.set_value("video", "ui_scale", video_ui_scale)
	
	config_file.set_value("video", "shadow_detail", video_shadow_detail)
	config_file.set_value("video", "aa_method", video_aa_method)
	config_file.set_value("video", "msaa_samples", video_msaa_samples)
	config_file.set_value("video", "ssao", video_ssao)
	config_file.set_value("video", "skybox_radiance_detail",
		video_skybox_radiance_detail)
	
	config_file.set_value("video", "depth_of_field", video_depth_of_field)
	config_file.set_value("video", "depth_of_field_amount",
		video_depth_of_field_amount)
	config_file.set_value("video", "depth_of_field_distance",
		video_depth_of_field_distance)
	
	config_file.set_value("video", "table_paint_filtering",
		video_table_paint_filtering)
	
	config_file.set_value("video", "brightness", video_brightness)
	config_file.set_value("video", "contrast", video_contrast)
	config_file.set_value("video", "saturation", video_saturation)
	
	# We also want to save the current bindings, but we only want to save them
	# if they differ from the default!
	var binding_manager := BindingManager.new()
	flag_using_old_binding_system = false
	
	for action in _configurable_actions:
		var keyboard_0_binding := binding_manager.get_keyboard_binding(
			action, 0)
		var keyboard_0_default := binding_manager.get_keyboard_binding_default(
			action, 0)
		if binding_manager.are_bindings_equal(keyboard_0_binding, keyboard_0_default):
			keyboard_0_binding = null
		elif keyboard_0_binding == null:
			# If we are clearing a binding that exists by default, we can't use
			# null as the binding will just come back once we restart the game.
			# It is impossible for the user to input an InputEventAction, so we
			# can use that to represent "no binding".
			keyboard_0_binding = InputEventAction.new()
		
		var keyboard_1_binding := binding_manager.get_keyboard_binding(
			action, 1)
		var keyboard_1_default := binding_manager.get_keyboard_binding_default(
			action, 1)
		if binding_manager.are_bindings_equal(keyboard_1_binding, keyboard_1_default):
			keyboard_1_binding = null
		elif keyboard_1_binding == null:
			keyboard_1_binding = InputEventAction.new()
		
		var controller_binding := binding_manager.get_controller_binding(
			action, 0)
		var controller_default := binding_manager.get_controller_binding_default(
			action, 0)
		if binding_manager.are_bindings_equal(controller_binding, controller_default):
			controller_binding = null
		elif controller_binding == null:
			controller_binding = InputEventAction.new()
		
		if keyboard_0_binding != null:
			config_file.set_value("keyboard_bindings_0", action,
					keyboard_0_binding)
		
		if keyboard_1_binding != null:
			config_file.set_value("keyboard_bindings_1", action,
					keyboard_1_binding)
		
		if controller_binding != null:
			config_file.set_value("controller_bindings_0", action,
					controller_binding)
	
	# Now that the ConfigFile has been filled out, we can override the values
	# if the caller wants us to.
	for key in overrides:
		var override_property: String = key
		var override_sections := override_property.split("_", false, 1)
		if override_sections.size() != 2:
			push_error("Invalid override name '%s'" % override_property)
			continue
		
		var override_section := override_sections[0]
		var override_key := override_sections[1]
		
		# NOTE: This section assumes that the names of the class' properties
		# are the same as those that are saved to the ConfigFile.
		if not config_file.has_section_key(override_section, override_key):
			push_error("Override key '%s/%s' does not exist in ConfigFile" %
				[override_section, override_key])
			continue
		
		var override_value = overrides[key]
		var override_type := typeof(override_value)
		
		var current_value = config_file.get_value(override_section, override_key)
		var current_type := typeof(current_value)
		
		if override_type != current_type:
			push_error("Override value for key '%s/%s' does not match existing type (expected: %s, got: %s)" %
				[override_section, override_key,
				SanityCheck.get_type_name(current_type),
				SanityCheck.get_type_name(override_type)])
			continue
		
		if override_value != current_value:
			config_file.set_value(override_section, override_key, override_value)
			print("GameConfig: Saved value for setting '%s/%s' was overwritten to '%s'." %
				[override_section, override_key, str(override_value)])
	
	print("GameConfig: Saving settings to '%s' ..." % CONFIG_FILE_PATH)
	
	var err := config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		push_error("Failed to save game settings to '%s' (error: %d)" % [
			CONFIG_FILE_PATH, err])


## Get a localised description of the given property to be shown in the UI.
func get_description(property_name: String) -> String:
	match property_name:
		"audio_master_volume":
			return tr("Sets the overall volume of the game.")
		"audio_music_volume":
			return tr("Sets the volume of music played in both the main menu, and in the game.")
		"audio_sounds_volume":
			return tr("Sets the volume of sounds played through speaker objects in the game.")
		"audio_effects_volume":
			return tr("Sets the volume of sound effects emitted by objects, for example, when they collide with the table.")
		
		"control_horizontal_sensitivity":
			return tr("Sets how fast the camera rotates horizontally.")
		"control_vertical_sensitivity":
			return tr("Sets how fast the camera rotates vertically.")
		"control_horizontal_invert":
			return tr("If enabled, the direction the camera rotates in horizontally will be inverted.")
		"control_vertical_invert":
			return tr("If enabled, the direction the camera rotates in vertically will be inverted.")
		"control_camera_movement_speed":
			return tr("Sets how fast the camera moves across the table.")
		"control_left_mouse_button_moves_camera":
			return tr("If enabled, holding down the Left Mouse Button will drag the camera across the table instead of making a box selection.")
		"control_zoom_sensitivity":
			return tr("Sets how fast the camera zooms in and out from the table.")
		"control_zoom_invert":
			return tr("If enabled, the direction the camera zooms in is invereted.")
		"control_piece_lift_sensitivity":
			return tr("Sets how fast objects are lifted up and down from the table.")
		"control_piece_lift_invert":
			return tr("If enabled, the direction objects are lifted in is inverted.")
		"control_piece_rotation_invert":
			return tr("If enabled, the direction objects are rotated in is inverted.")
		"control_hand_preview_enabled":
			return tr("If enabled, hovering over a card in your hand for a short period of time will display an enhanced preview of the card.")
		"control_hand_preview_delay":
			return tr("Sets how long in seconds the mouse needs to be hovering over a card in your hand before a preview is displayed.")
		"control_hand_preview_size":
			return tr("Sets how big the preview is when hovering over a card in your hand.")
		"control_hide_hints":
			return tr("If enabled, the control hints shown in the corner of the screen will be hidden.")
		
		"general_language":
			return tr("Sets the language that the game displays text in.")
		"general_autosave_interval":
			return tr("Sets how often the game will automatically save.")
		"general_autosave_file_count":
			return tr("Sets the maximum number of autosaves that can exist at any given time.")
		"general_skip_splash_screen":
			return tr("If enabled, the Godot Engine splash screen at the start of the game will no longer be shown.")
		"general_show_warnings":
			return tr("If enabled, system warnings will be shown in the chat window.")
		"general_show_errors":
			return tr("If enabled, system errors will be shown in the chat window.")
		
		"multiplayer_name":
			return tr("Sets the name used to represent you.")
		"multiplayer_color":
			return tr("Sets the colour used to represent you.")
		"multiplayer_chat_font_size":
			return tr("Sets how big the text should be in the chat window.")
		"multiplayer_hide_cursors":
			return tr("If enabled, other player's cursors will no longer be visible.")
		"multiplayer_censor_profanity":
			return tr("If enabled, offensive words will automatically be filtered out of messages sent by you and other players.")
		
		"video_window_mode":
			var t := tr("Sets how the operating system will display the game window.")
			
			if OS.get_name() == "OSX":
				t += "\n" + tr("NOTE: This option is not available on macOS, however, you can still toggle fullscreen mode by clicking the green maximise button.")
			
			return t
		"video_fov":
			return tr("Sets how wide the camera's field of view should be in degrees.")
		"video_vsync":
			return tr("If enabled, the game will render new frames only when the monitor is ready to display a new frame, ensuring that the game's frame rate matches that of the monitor's refresh rate. This option eliminates screen tearing artifacts, but may introduce some input latency.")
		"video_ui_scale":
			return tr("Sets how big the user interface should appear relative to it's default size.")
		"video_shadow_detail":
			return tr("Sets the quality of shadows that are cast in the room. The more detail that shadows have, the better they look, but at the cost of performance.")
		"video_aa_method":
			return tr("Anti-aliasing is a technique used to smooth the appearance of jagged edges.") \
				+ "\n" + tr("FXAA: Uses an approximation algorithm. Better performance, but some edges may appear blurry.") \
				+ "\n" + tr("MSAA: Uses a supersampling algorithm. More accurate, but at a significant cost to performance.")
		"video_msaa_samples":
			return tr("Sets how many samples should be used when performing multisample anti-aliasing (MSAA).")
		"video_ssao":
			return tr("Sets the quality when performing screen space ambient occlusion. Ambient occlusion is a technique used to predict how much surfaces are exposed to ambient lighting. The higher the quality, the more realistic the lighting, at a significant cost to performance.")
		"video_skybox_radiance_detail":
			return tr("Sets the quality of light radiating from the skybox. The higher the quality, the more detailed reflections of the skybox are, but at the cost of performance.")
		"video_depth_of_field":
			return tr("Sets the quality of the depth of field effect. Depth of field is a technique used to blur objects that are not in focus. The higher the quality, the better the blur looks, but at the cost of performance.")
		"video_depth_of_field_amount":
			return tr("Sets how much the background is blurred when using depth of field.")
		"video_depth_of_field_distance":
			return tr("Sets how far away from the camera the threshold of what is considered the background is when using depth of field.")
		"video_table_paint_filtering":
			return tr("If enabled, the paint on the table is blurred slightly so as to not look pixelated.")
		"video_brightness":
			return tr("Sets how bright each rendered frame is.")
		"video_contrast":
			return tr("Sets how much contrast there is in each rendered frame.")
		"video_saturation":
			return tr("Sets how much colour saturation there is in each rendered frame.")
		
		_:
			return ""


## Apply the current configuration to the entire game.
## NOTE: This will emit [signal applying_settings].
func apply_all() -> void:
	print("GameConfig: Applying all settings...")
	
	apply_audio()
	set_locale(general_language)
	
	set_window_mode(video_window_mode)
	OS.vsync_enabled = video_vsync
	set_ui_scale(video_ui_scale)
	
	set_shadow_detail(video_shadow_detail)
	set_viewport_aa(video_aa_method, video_msaa_samples)
	
	emit_signal("applying_settings")


## Apply only the current audio configuration.
func apply_audio() -> void:
	set_audio_bus_volume("Master", audio_master_volume)
	set_audio_bus_volume("Music", audio_music_volume)
	set_audio_bus_volume("Sounds", audio_sounds_volume)
	set_audio_bus_volume("Effects", audio_effects_volume)


## Set the volume level (from 0-1) of the given audio bus.
func set_audio_bus_volume(bus_name: String, bus_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_error("Cannot set volume of audio bus '%s', does not exist" % bus_name)
		return
	
	var mute_bus := is_zero_approx(bus_volume)
	AudioServer.set_bus_mute(bus_index, mute_bus)
	
	if not mute_bus:
		var volume_db := convert_volume_to_db(bus_volume)
		AudioServer.set_bus_volume_db(bus_index, volume_db)


## Converts a volume level (from 0-1) into a dB level (from -INF to -6) that
## can be used by the [AudioServer] to set the dB level of an audio bus.
func convert_volume_to_db(volume: float) -> float:
	return 8.656170245 * log(0.5 * volume)


## Set the game's current locale. If the string is empty, then the one closest
## to the system's locale is chosen.
func set_locale(locale: String) -> void:
	if locale.empty():
		var system_locale := OS.get_locale()
		var closest_locale := find_closest_locale(system_locale)
		if closest_locale.empty():
			TranslationServer.set_locale("en")
		else:
			TranslationServer.set_locale(closest_locale)
	else:
		TranslationServer.set_locale(locale)


## Given a locale code that potentially includes a variant (e.g. de_AT), find
## the closest locale that is supported by the game (e.g. de). If none are
## found, an empty string is returned.
func find_closest_locale(locale_code: String) -> String:
	if locale_code.empty():
		return ""
	
	var closest_locale := ""
	
	for element in TranslationServer.get_loaded_locales():
		var potential_locale: String = element
		if potential_locale.length() <= closest_locale.length():
			continue
		
		if locale_code.begins_with(potential_locale):
			closest_locale = potential_locale
	
	return closest_locale


## Set the way in which the game window is displayed by the operating system.
## For example, [code]MODE_WINDOWED[/code].
func set_window_mode(window_mode: int) -> void:
	# Trying to set the window mode on macOS results in weird behaviour, and
	# eventually leads to a permanent black screen on the next launch.
	if OS.get_name() == "OSX":
		return
	
	# Settings for windowed mode.
	var is_fullscreen := false
	var is_borderless := false
	var is_maximized := OS.window_maximized
	
	match window_mode:
		MODE_BORDERLESS_FULLSCREEN:
			is_borderless = true
			is_maximized = true
		MODE_FULLSCREEN:
			is_fullscreen = true
			is_borderless = true
	
	OS.window_fullscreen = is_fullscreen
	OS.window_borderless = is_borderless
	OS.window_maximized = is_maximized


## Sets the scale of UI elements across the game.
func set_ui_scale(ui_scale: float) -> void:
	var stretch_mode_str: String = ProjectSettings.get_setting(
		"display/window/stretch/mode")
	var stretch_mode := SceneTree.STRETCH_MODE_DISABLED
	
	match stretch_mode_str:
		"disabled":
			stretch_mode = SceneTree.STRETCH_MODE_DISABLED
		"2d":
			stretch_mode = SceneTree.STRETCH_MODE_2D
		"viewport":
			stretch_mode = SceneTree.STRETCH_MODE_VIEWPORT
		_:
			push_error("Unknown value '%s' for project setting 'display/window/stretch/mode'" %
				stretch_mode_str)
			return
	
	var stretch_aspect_str: String = ProjectSettings.get_setting(
		"display/window/stretch/aspect")
	var stretch_aspect := SceneTree.STRETCH_ASPECT_IGNORE
	
	match stretch_aspect_str:
		"ignore":
			stretch_aspect = SceneTree.STRETCH_ASPECT_IGNORE
		"keep":
			stretch_aspect = SceneTree.STRETCH_ASPECT_KEEP
		"keep_width":
			stretch_aspect = SceneTree.STRETCH_ASPECT_KEEP_WIDTH
		"keep_height":
			stretch_aspect = SceneTree.STRETCH_ASPECT_KEEP_HEIGHT
		"expand":
			stretch_aspect = SceneTree.STRETCH_ASPECT_EXPAND
		_:
			push_error("Unknown value '%s' for project setting 'display/window/stretch/aspect'" %
				stretch_aspect_str)
			return
	
	var min_size := Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)
	
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, min_size,
		ui_scale)
	
	# Pop-ups will need to adjust their position if the scale changes.
	get_tree().emit_signal("screen_resized")


## Set the shadow filter and size at runtime. For example,
## [code]SHADOW_DETAIL_MEDIUM[/code].
func set_shadow_detail(shadow_detail: int) -> void:
	var shadow_filter: int = ProjectSettings.get_setting(
		"rendering/quality/shadows/filter_mode")
	var shadow_size: int = ProjectSettings.get_setting(
		"rendering/quality/directional_shadow/size")
	
	match shadow_detail:
		SHADOW_DETAIL_LOW:
			shadow_filter = 1 # PCF5.
			shadow_size = 2048
		SHADOW_DETAIL_MEDIUM:
			shadow_filter = 1 # PCF5.
			shadow_size = 4096
		SHADOW_DETAIL_HIGH:
			shadow_filter = 2 # PCF13.
			shadow_size = 8192
		SHADOW_DETAIL_VERY_HIGH:
			shadow_filter = 2 # PCF13.
			shadow_size = 16384
	
	# Used by shadows cast by all lights.
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode",
		shadow_filter)
	
	# Used by DirectionalLights.
	ProjectSettings.set_setting("rendering/quality/directional_shadow/size",
		shadow_size)
	
	# Used by OmniLights and SpotLights.
	get_viewport().shadow_atlas_size = shadow_size


## Set the anti-aliasing method used by the viewport, e.g. [code]AA_FXAA[/code].
## If using MSAA, the number of samples also needs to be provided, for example,
## [code]MSAA_4X[/code].
func set_viewport_aa(aa_method: int, msaa_samples: int) -> void:
	var fxaa_enabled := false
	var sharpening := 0.0
	var msaa_setting := Viewport.MSAA_DISABLED
	
	match aa_method:
		AA_FXAA:
			fxaa_enabled = true
			sharpening = 0.5
		AA_MSAA:
			match msaa_samples:
				MSAA_2X:
					msaa_setting = Viewport.MSAA_2X
				MSAA_4X:
					msaa_setting = Viewport.MSAA_4X
				MSAA_8X:
					msaa_setting = Viewport.MSAA_8X
				MSAA_16X:
					msaa_setting = Viewport.MSAA_16X
	
	get_viewport().fxaa = fxaa_enabled
	get_viewport().sharpen_intensity = sharpening
	get_viewport().msaa = msaa_setting


func set_audio_master_volume(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	# TODO: Replace instances of max(..., min(...)) with clamp().
	audio_master_volume = clamp(value, 0.0, 1.0)


func set_audio_music_volume(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	audio_music_volume = clamp(value, 0.0, 1.0)


func set_audio_sounds_volume(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	audio_sounds_volume = clamp(value, 0.0, 1.0)


func set_audio_effects_volume(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	audio_effects_volume = clamp(value, 0.0, 1.0)


func set_control_horizontal_sensitivity(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_horizontal_sensitivity = clamp(value, 0.01, 1.0)


func set_control_vertical_sensitivity(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_vertical_sensitivity = clamp(value, 0.01, 1.0)


func set_control_camera_movement_speed(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_camera_movement_speed = clamp(value, 0.01, 1.0)


func set_control_zoom_sensitivity(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_zoom_sensitivity = clamp(value, 0.01, 1.0)


func set_control_piece_lift_sensitivity(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_piece_lift_sensitivity = clamp(value, 0.01, 1.0)


func set_control_hand_preview_delay(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_hand_preview_delay = clamp(value, 0.01, 1.0)


func set_control_hand_preview_size(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	control_hand_preview_size = clamp(value, 0.01, 1.0)


func set_general_language(value: String) -> void:
	value = value.strip_edges().strip_escapes()
	general_language = find_closest_locale(value)


func set_general_autosave_interval(value: int) -> void:
	if value < 0 or value > AUTOSAVE_MAX:
		return
	
	general_autosave_interval = value


func set_general_autosave_file_count(value: int) -> void:
	if value < 1:
		return
	
	general_autosave_file_count = value


func set_multiplayer_name(value: String) -> void:
	value = value.substr(0, 100)
	value = value.strip_edges().strip_escapes()
	
	if value.empty():
		return
	
	multiplayer_name = value


func set_multiplayer_color(value: Color) -> void:
	if not SanityCheck.is_valid_color(value):
		return
	
	value.a = 1.0
	multiplayer_color = value


func set_multiplayer_chat_font_size(value: int) -> void:
	if value < 0 or value >= FONT_SIZE_MAX:
		return
	
	multiplayer_chat_font_size = value


func set_video_window_mode(value: int) -> void:
	if value < 0 or value >= MODE_MAX:
		return
	
	video_window_mode = value


func set_video_fov(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_fov = clamp(value, 50.0, 130.0)


func set_video_ui_scale(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_ui_scale = clamp(value, 0.5, 1.25)


func set_video_shadow_detail(value: int) -> void:
	if value < 0 or value >= SHADOW_DETAIL_MAX:
		return
	
	video_shadow_detail = value


func set_video_aa_method(value: int) -> void:
	if value < 0 or value >= AA_MAX:
		return
	
	video_aa_method = value


func set_video_msaa_samples(value: int) -> void:
	if value < 0 or value >= MSAA_MAX:
		return
	
	video_msaa_samples = value


func set_video_ssao(value: int) -> void:
	if value < 0 or value >= SSAO_MAX:
		return
	
	video_ssao = value


func set_video_skybox_radiance_detail(value: int) -> void:
	if value < 0 or value >= RADIANCE_MAX:
		return
	
	video_skybox_radiance_detail = value


func set_video_depth_of_field(value: int) -> void:
	if value < 0 or value >= DOF_MAX:
		return
	
	video_depth_of_field = value


func set_video_depth_of_field_amount(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_depth_of_field_amount = clamp(value, 0.01, 1.0)


func set_video_depth_of_field_distance(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_depth_of_field_distance = clamp(value, 0.01, 1.0)


func set_video_brightness(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_brightness = clamp(value, 0.1, 3.0)


func set_video_contrast(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_contrast = clamp(value, 0.1, 3.0)


func set_video_saturation(value: float) -> void:
	if not SanityCheck.is_valid_float(value):
		return
	
	video_saturation = clamp(value, 0.1, 3.0)


func set_flag_using_old_binding_system(_value: bool) -> void:
	# We do not want to change this value from the outside.
	return