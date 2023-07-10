# tabletop-club
# Copyright (c) 2020-2023 Benjamin 'drwhut' Beddows.
# Copyright (c) 2021-2023 Tabletop Club contributors (see game/CREDITS.tres).
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

class_name AssetPackTypeCatalog
extends TaggedDirectory

## Used to import and catalog assets from an asset pack subdirectory.


func _init(path: String).(path):
	pass


## Collect audio assets using [method collect_assets].
func collect_audio(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_AUDIO)


## Collect save files using [method collect_assets].
func collect_saves(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_SAVE)


## Collect scene assets using [method collect_assets].
func collect_scenes(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_SCENE_USER)


## Collect scene support files using [method collect_assets].
func collect_support(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_SCENE_SUPPORT)


## Collect notebook text templates using [method collect_assets].
func collect_text_templates(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_TEMPLATE_TEXT)


## Collect texture assets using [method collect_assets].
func collect_textures(from_dir: String) -> Array:
	return collect_assets(from_dir, SanityCheck.VALID_EXTENSIONS_TEXTURE)


## Collect assets from the given directory that have a specific set of
## extensions. All assets that are collected are automatically tagged.
## Returns the list of assets that were collected.
func collect_assets(from_dir: String, extension_arr: Array) -> Array:
	var scan_dir := Directory.new()
	if not scan_dir.dir_exists(from_dir):
		push_error("Error scanning '%s' for assets, does not exist" % from_dir)
		return []
	
	var err := scan_dir.open(from_dir)
	if err != OK:
		push_error("Error opening '%s' to scan assets (error: %d)" % [from_dir, err])
		return []
	
	err = scan_dir.list_dir_begin(true, true)
	if err != OK:
		push_error("Error scanning files from '%s' (error: %d)" % [from_dir, err])
		return []
	
	var scanned_assets := []
	var file_name := scan_dir.get_next()
	while not file_name.empty():
		if not scan_dir.current_is_dir():
			if file_name.get_extension() in extension_arr:
				_copy_file(from_dir, file_name)
				
				if not is_tagged(file_name):
					tag(file_name, true)
				
				scanned_assets.push_back(file_name)
		
		file_name = scan_dir.get_next()
	
	return scanned_assets


## Automatically import all of the currently tagged files in the directory.
## If a file has already been imported from before, it is skipped.
func import_tagged() -> void:
	var tagged_arr := get_tagged()
	for tagged_file in tagged_arr:
		if not tagged_file.get_extension() in SanityCheck.VALID_EXTENSIONS_IMPORT:
			continue
		
		if is_imported(tagged_file) and not (is_new(tagged_file) or \
				is_changed(tagged_file)):
			continue
		
		import_file(tagged_file)


## Import a file from [code]dir_path[/code] using the custom module. The file
## itself, as well as any dependencies of the file (e.g. material files), are
## automatically tagged if they are not already. Returns an error code.
func import_file(file_name: String) -> int:
	if not CustomModule.is_loaded():
		push_error("Cannot import '%s', custom module is not loaded" % file_name)
		return ERR_UNAVAILABLE
	
	if not file_name.is_valid_filename():
		push_error("Error importing '%s', invalid file name" % file_name)
		return ERR_INVALID_PARAMETER
	
	if not file_name.get_extension() in SanityCheck.VALID_EXTENSIONS_IMPORT:
		push_error("Error importing '%s', extension is not importable" % file_name)
		return ERR_INVALID_PARAMETER
	
	var file_path := dir_path.plus_file(file_name)
	var file := File.new()
	if not file.file_exists(file_path):
		push_error("Error importing '%s', file does not exist" % file_path)
		return ERR_FILE_NOT_FOUND
	
	print("Importing: %s" % file_path)
	
	# TODO: If files are deleted from the main directory, then files generated
	# from importing will stay in user://.import - there should be a way to
	# clean these files, probably in a higher-order class.
	
	var import_basename := _get_meta_basename(file_name)
	var err: int = CustomModule.tabletop_importer.call("import", file_path,
			import_basename, {})
	if err != OK:
		push_error("Error importing '%s' (error: %d)" % [file_path, err])
		return err
	
	var files_to_tag := [file_path, file_path + ".import"]
	while not files_to_tag.empty():
		var current_path: String = files_to_tag.pop_front()
		if not current_path.is_abs_path():
			push_warning("Dependency path '%s' is not absolute, ignoring" % current_path)
			continue
		
		if current_path.get_base_dir() != dir_path:
			push_warning("Dependency path '%s' is not in expected directory '%s', ignoring" % [
					current_path, dir_path])
			continue
		
		var current_name := current_path.get_file()
		if not is_tagged(current_name):
			# No need to store metadata about generated files, as they will
			# change anyway if the original file changes.
			tag(current_name, false)
		
		# The file needs to be a valid resource to have dependencies.
		if not ResourceLoader.exists(current_path):
			continue
		
		var file_deps := ResourceLoader.get_dependencies(current_path)
		files_to_tag.append_array(file_deps)
	
	return OK


## Check if the given file has been imported properly. This function is mainly
## used for testing, and is slightly more robust than
## [code]ResourceLoader.exists[/code].
func is_imported(file_name: String) -> bool:
	if not file_name.is_valid_filename():
		push_warning("Cannot check if '%s' was imported, not a valid file name" % file_name)
		return false
	
	var this_dir := get_dir()
	if not this_dir.file_exists(file_name):
		push_warning("Cannot check if '%s' was imported, file does not exist" % file_name)
		return false
	
	if not this_dir.file_exists(file_name + ".import"):
		return false
	
	var import_file := ConfigFile.new()
	var import_file_path := dir_path.plus_file(file_name + ".import")
	var err := import_file.load(import_file_path)
	if err != OK:
		push_error("Failed to load '%s' (error: %d)" % [import_file_path, err])
		return false
	
	var remap_keys := import_file.get_section_keys("remap")
	var num_paths := 0
	for key in remap_keys:
		if not key.begins_with("path"):
			continue
		
		var path = import_file.get_value("remap", key, "")
		if not path is String:
			return false
		if path.empty():
			return false
		if not this_dir.file_exists(path):
			return false
		
		num_paths += 1
	
	return num_paths > 0


## Apply the properties of a config.cfg file to the given entry.
## [code]full_name[/code] is used to decide which sections of the file to get
## properties from.
func apply_config_to_entry(entry: AssetEntrySingle, config: AdvancedConfigFile,
		full_name: String, scale_is_vec2: bool, die_num_faces: int) -> void:
	
	# TODO: Make sure any errors that come up (either from the config file, or
	# from the entry itself) are stored in the entry.
	print("Configuring: %s" % full_name)
	
	entry.id = config.get_value_by_matching(full_name, "name",
			full_name.get_basename(), true)
	entry.desc = config.get_value_by_matching(full_name, "desc", "", true)
	
	entry.author = config.get_value_by_matching(full_name, "author", "", true)
	entry.license = config.get_value_by_matching(full_name, "license", "", true)
	entry.modified_by = config.get_value_by_matching(full_name, "modified_by",
			"", true)
	entry.url = config.get_value_by_matching(full_name, "url", "", true)
	
	# TODO: Ideally would use elif's here, but due to how the autocompletion
	# works, it won't show the subclass's properties. Change once the editor
	# has improved in this regard.
	
	if entry is AssetEntryAudio:
		pass # Everything is determined by the directory the track is in.
	
	if entry is AssetEntryScene:
		var color_str: String = config.get_value_by_matching(full_name, "color",
				"#ffffff", true)
		if color_str.is_valid_html_color():
			entry.albedo_color = Color(color_str)
		else:
			push_error("'%s' is not a valid color" % color_str)
		
		# TODO: Throw a warning if values like these are invalid? From within
		# the class itself or here?
		entry.mass = config.get_value_by_matching(full_name, "mass", 1.0, true)
		
		if scale_is_vec2:
			# TODO: Should Vector3 be allowed with a warning here?
			var scale_vec2: Vector2 = config.get_value_by_matching(full_name,
					"scale", Vector2.ONE, true)
			entry.scale = Vector3(scale_vec2.x, 1.0, scale_vec2.y)
		else:
			entry.scale = config.get_value_by_matching(full_name, "scale",
					Vector3.ONE, true)
		
		# Now that we know the scale, we can use it to automatically adjust the
		# meta-properties of the scene.
		entry.avg_point *= entry.scale
		var old_aabb: AABB = entry.bounding_box
		entry.bounding_box = AABB(entry.scale * old_aabb.position,
				entry.scale * old_aabb.size)
		
		if entry.scene_path.begins_with("res://"):
			# In-built scenes should already be configured with the correct
			# collision shape and centre-of-mass, so do not allow the player
			# to modify these.
			entry.collision_type = AssetEntryScene.CollisionType.COLLISION_NONE
			entry.com_adjust = AssetEntryScene.ComAdjust.COM_ADJUST_OFF
		else:
			var collision_cfg: int = config.get_value_by_matching(full_name,
					"collision_mode", 0, true)
			match collision_cfg:
				0:
					entry.collision_type = AssetEntryScene.CollisionType.COLLISION_CONVEX
				1:
					entry.collision_type = AssetEntryScene.CollisionType.COLLISION_MULTI_CONVEX
				2:
					entry.collision_type = AssetEntryScene.CollisionType.COLLISION_CONCAVE
				_:
					push_error("Invalid value (%d) for property 'collision_mode'" % collision_cfg)
					entry.collision_type = AssetEntryScene.CollisionType.COLLISION_CONVEX
			
			var com_cfg: String = config.get_value_by_matching(full_name,
					"com_adjust", "volume", true)
			match com_cfg:
				"off":
					entry.com_adjust = AssetEntryScene.ComAdjust.COM_ADJUST_OFF
				"volume":
					entry.com_adjust = AssetEntryScene.ComAdjust.COM_ADJUST_VOLUME
				"geometry":
					entry.com_adjust = AssetEntryScene.ComAdjust.COM_ADJUST_GEOMETRY
				_:
					push_error("Invalid value ('%s') for property 'com_adjust'" % com_cfg)
					entry.com_adjust = AssetEntryScene.ComAdjust.COM_ADJUST_VOLUME
		
		# TODO: Allow all properties of the physics material to be configured.
		var default_phys_mat := preload("res://assets/default_physics_material.tres")
		
		# To save on memory, if the properties aren't changed, then just use the
		# default resource. If a property is changed, the resource will need to
		# be duplicated as to not overwrite the original resource.
		var scene_phys_mat := default_phys_mat
		
		var new_bounce: float = config.get_value_by_matching(full_name,
				"bounce", 0.0, true)
		if new_bounce != default_phys_mat.bounce:
			if scene_phys_mat == default_phys_mat:
				scene_phys_mat = scene_phys_mat.duplicate()
			scene_phys_mat.bounce = min(max(new_bounce, 0.0), 1.0)
		
		entry.physics_material = scene_phys_mat
		
		# TODO: If sound effects have already been configured for this entry,
		# then we do not allow the player to change them. Would it make sense
		# for the player to be able to change the SFX of, say, cards?
		var has_fast_sounds: bool = entry.collision_fast_sounds.has_stream()
		var has_slow_sounds: bool = entry.collision_slow_sounds.has_stream()
		
		if not (has_fast_sounds or has_slow_sounds):
			var fast_sfx: AudioStreamList
			var slow_sfx: AudioStreamList
			
			var sfx_cfg: String = config.get_value_by_matching(full_name, "sfx",
					"generic", true)
			match sfx_cfg:
				"generic":
					fast_sfx = preload("res://sounds/generic/generic_fast_sounds.tres")
					slow_sfx = preload("res://sounds/generic/generic_slow_sounds.tres")
				"glass":
					fast_sfx = preload("res://sounds/glass/glass_fast_sounds.tres")
					slow_sfx = preload("res://sounds/glass/glass_slow_sounds.tres")
				"glass_heavy":
					fast_sfx = preload("res://sounds/glass_heavy/glass_heavy_fast_sounds.tres")
					slow_sfx = preload("res://sounds/glass_heavy/glass_heavy_slow_sounds.tres")
				"glass_light":
					fast_sfx = preload("res://sounds/glass_light/glass_light_fast_sounds.tres")
					slow_sfx = preload("res://sounds/glass_light/glass_light_slow_sounds.tres")
				"metal":
					fast_sfx = preload("res://sounds/metal/metal_fast_sounds.tres")
					slow_sfx = preload("res://sounds/metal/metal_slow_sounds.tres")
				"metal_heavy":
					fast_sfx = preload("res://sounds/metal_heavy/metal_heavy_fast_sounds.tres")
					slow_sfx = preload("res://sounds/metal_heavy/metal_heavy_slow_sounds.tres")
				"metal_light":
					fast_sfx = preload("res://sounds/metal_light/metal_light_fast_sounds.tres")
					slow_sfx = preload("res://sounds/metal_light/metal_light_slow_sounds.tres")
				"soft":
					fast_sfx = preload("res://sounds/soft/soft_fast_sounds.tres")
					slow_sfx = preload("res://sounds/soft/soft_slow_sounds.tres")
				"soft_heavy":
					fast_sfx = preload("res://sounds/soft_heavy/soft_heavy_fast_sounds.tres")
					slow_sfx = preload("res://sounds/soft_heavy/soft_heavy_slow_sounds.tres")
				"tin":
					fast_sfx = preload("res://sounds/tin/tin_fast_sounds.tres")
					slow_sfx = preload("res://sounds/tin/tin_slow_sounds.tres")
				"wood":
					fast_sfx = preload("res://sounds/wood/wood_fast_sounds.tres")
					slow_sfx = preload("res://sounds/wood/wood_slow_sounds.tres")
				"wood_heavy":
					fast_sfx = preload("res://sounds/wood_heavy/wood_heavy_fast_sounds.tres")
					slow_sfx = preload("res://sounds/wood_heavy/wood_heavy_slow_sounds.tres")
				"wood_light":
					fast_sfx = preload("res://sounds/wood_light/wood_light_fast_sounds.tres")
					slow_sfx = preload("res://sounds/wood_light/wood_light_slow_sounds.tres")
				_:
					push_error("Invalid value ('%s') for property 'sfx'" % sfx_cfg)
					fast_sfx = preload("res://sounds/generic/generic_fast_sounds.tres")
					slow_sfx = preload("res://sounds/generic/generic_slow_sounds.tres")
			
			entry.collision_fast_sounds = fast_sfx
			entry.collision_slow_sounds = slow_sfx
		
		if entry is AssetEntryContainer:
			entry.shakable = config.get_value_by_matching(full_name, "shakable",
					false, true)
		
		if entry is AssetEntryDice:
			var value_dict: Dictionary = config.get_value_by_matching(full_name,
					"face_values", {}, true)
			
			var face_value_list_raw := []
			for key in value_dict:
				var rot_deg := Vector2.ZERO
				var custom_value := CustomValue.new()
				
				if typeof(key) == TYPE_VECTOR2:
					rot_deg = key
					custom_value.set_value_variant(value_dict[key])
				else:
					# This is for backwards compatibility with v0.1.x, where the
					# keys were the face values, and the values were the face
					# rotations. This method forced unique face values, which
					# is why the values have now been swapped as of v0.2.0
					push_warning("The VALUE: ROTATION notation for 'face_values' is deprecated as of v0.2.0 - consider changing to ROTATION: VALUE")
					custom_value.set_value_variant(key)
					var potential_rot = value_dict[key]
					if typeof(potential_rot) == TYPE_VECTOR2:
						rot_deg = potential_rot
					else:
						push_error("Rotation value in 'face_values' is not a Vector2")
						continue
				
				if not SanityCheck.is_valid_vector2(rot_deg):
					push_error("Vector2 in 'face_values' contains invalid data")
					continue
				
				var face_value := DiceFaceValue.new()
				face_value.set_normal_with_euler(deg2rad(rot_deg.x),
						deg2rad(rot_deg.y))
				face_value.value = custom_value
				face_value_list_raw.push_back(face_value)
			
			if face_value_list_raw.size() != die_num_faces:
				push_warning("'face_values' size was not the expected value (expected: %d, got: %d)" % [
						die_num_faces, face_value_list_raw.size()])
			
			if face_value_list_raw.empty():
				var current_list: DiceFaceValueList = entry.face_value_list
				var current_list_raw: Array = current_list.face_value_list
				
				# Only replace the default resource if we need to, there's no
				# point in making a bunch of empty instances.
				if not current_list_raw.empty():
					entry.face_value_list = DiceFaceValueList.new()
			else:
				var res_list := DiceFaceValueList.new()
				res_list.face_value_list = face_value_list_raw
				entry.face_value_list = res_list
		
		if entry is AssetEntryStackable:
			var suit_cfg = config.get_value_by_matching(full_name, "suit", null,
					false)
			var suit_custom_value := CustomValue.new()
			suit_custom_value.set_value_variant(suit_cfg)
			entry.user_suit = suit_custom_value
			
			var value_cfg = config.get_value_by_matching(full_name, "value",
					null, false)
			var value_custom_value := CustomValue.new()
			value_custom_value.set_value_variant(value_cfg)
			entry.user_value = value_custom_value
		
		if entry is AssetEntryTable:
			var hand_cfg: Array = config.get_value_by_matching(full_name,
					"hands", [], true)
			
			var hand_transform_arr := []
			for hand_dict in hand_cfg:
				if not hand_dict is Dictionary:
					push_error("Element of 'hands' is invalid, not a dictionary")
					continue
				
				var parser := DictionaryParser.new(hand_dict)
				var hand_pos: Vector3 = parser.get_strict_type("pos", Vector3.ZERO)
				var hand_rot_deg: float = parser.get_strict_type("dir", 0.0)
				
				# TODO: Should the SanityCheck functions log errors to resources?
				if not SanityCheck.is_valid_vector3(hand_pos):
					push_error("Value of 'pos' is invalid")
					continue
				if not SanityCheck.is_valid_float(hand_rot_deg):
					push_error("Value of 'dir' is invalid")
					continue
				
				var hand_transform := Transform.IDENTITY
				hand_transform = hand_transform.rotated(Vector3.UP,
						deg2rad(hand_rot_deg))
				hand_transform.origin = hand_pos
				hand_transform_arr.push_back(hand_transform)
			
			if hand_transform_arr.empty():
				push_warning("Table has no configured hand positions, consider adding at least one via the 'config.cfg' file")
			entry.hand_transforms = hand_transform_arr
			
			# TODO: Make this a constant somewhere else?
			var default_plane_size := Vector2(100.0, 100.0)

			var paint_plane_size: Vector2 = config.get_value_by_matching(
					full_name, "paint_plane", default_plane_size, true)
			if SanityCheck.is_valid_vector2(paint_plane_size):
				paint_plane_size = paint_plane_size.abs()
			else:
				push_error("'paint_plane' contains invalid data")
				paint_plane_size = default_plane_size
			
			var paint_plane_transform := Transform.IDENTITY
			paint_plane_transform = paint_plane_transform.scaled(Vector3(
					paint_plane_size.x, 1.0, paint_plane_size.y))
			entry.paint_plane_transform = paint_plane_transform
	
	
	if entry is AssetEntrySkybox:
		entry.energy = config.get_value_by_matching(full_name, "strength", 1.0, true)
		
		var rot_deg: Vector3 = config.get_value_by_matching(full_name,
				"rotation", Vector3.ZERO, true)
		var rot_rad := Vector3(deg2rad(rot_deg.x), deg2rad(rot_deg.y),
				deg2rad(rot_deg.z))
		entry.rotation = rot_rad
	
	if entry is AssetEntryTemplate:
		if entry is AssetEntryTemplateImage:
			var textbox_arr := []
			var textbox_input = config.get_value_by_matching(full_name,
					"textboxes", [], false)
			
			if textbox_input is Array:
				textbox_arr = textbox_input
			elif textbox_input is Dictionary:
				push_warning("'textboxes' is now an array as of v0.2.0, ignoring keys")
				textbox_arr = textbox_input.values()
			else:
				push_error("'textboxes' is invalid data type (expected: Array, got: %s)" %
						SanityCheck.get_type_name(typeof(textbox_input)))
			
			entry.textbox_list = []
			for textbox_meta in textbox_arr:
				if not textbox_meta is Dictionary:
					push_warning("Element of 'textboxes' array is not a dictionary, ignoring")
					continue
				
				var new_textbox := TemplateTextbox.new()
				var parser := DictionaryParser.new(textbox_meta)
				
				# TODO: Do we want to check the image size here, even though
				# the textbox can be rotated?
				var x: int = parser.get_strict_type("x", 0)
				var y: int = parser.get_strict_type("y", 0)
				var w: int = parser.get_strict_type("w", 100)
				var h: int = parser.get_strict_type("h", 100)
				new_textbox.rect = Rect2(x, y, w, h)
				
				new_textbox.rotation = parser.get_strict_type("rot", 0.0)
				new_textbox.lines = parser.get_strict_type("lines", 1)
				new_textbox.text = parser.get_strict_type("text", "")
				
				entry.textbox_list.push_back(new_textbox)
		
		if entry is AssetEntryTemplateText:
			pass


# Copy a file from from_dir to dir_path, but only if necessary.
func _copy_file(from_dir: String, file_name: String) -> void:
	var src_path := from_dir.plus_file(file_name)
	var dst_path := dir_path.plus_file(file_name)
	
	var file := File.new()
	var src_md5 := file.get_md5(src_path)
	var dst_md5 := ""
	if file.file_exists(dst_path):
		dst_md5 = file.get_md5(dst_path)
	
	if src_md5 != dst_md5:
		var dir := Directory.new()
		dir.copy(src_path, dst_path)
		print("Copied: %s -> %s" % [src_path, dst_path])