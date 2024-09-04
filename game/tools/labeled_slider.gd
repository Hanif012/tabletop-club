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

tool
class_name LabeledSlider
extends HBoxContainer

## A horizontal slider with a label showing the current value.


## Emitted when the value of the slider has been changed.
signal value_changed(new_value)


## The minimum value of the slider.
export(float) var min_value := 0.0 setget set_min_value, get_min_value

## The maximum value of the slider.
export(float) var max_value := 1.0 setget set_max_value, get_max_value

## The step value of the slider.
export(float) var step := 0.01 setget set_step, get_step

## The current value of the slider.
export(float) var value := 0.0 setget set_value, get_value

## The prefix before the value.
export(String) var prefix := "" setget set_prefix

## The suffix after the value.
export(String) var suffix := "" setget set_suffix

## Should the value be shown as an integer?
export(bool) var display_integer := false setget set_display_integer

## Should the value be shown as a percentage?
export(bool) var display_percentage := false setget set_display_percentage

## How much the value should be scaled before it is displayed.
export(float) var display_scalar := 1.0 setget set_display_scalar

## The width of the display label.
export(float, 0.0, 1000.0) var display_width := 50.0 \
		setget set_display_width, get_display_width

## The font to use for the new label.
export(Font) var font_override: Font = null \
		setget set_font_override, get_font_override

## The slider's focus neighbour to the left.
export(NodePath) var slider_focus_left: NodePath \
		setget set_slider_focus_left, get_slider_focus_left

## The slider's focus neighbour to the top.
export(NodePath) var slider_focus_top: NodePath \
		setget set_slider_focus_top, get_slider_focus_top

## The slider's focus neighbour to the right.
export(NodePath) var slider_focus_right: NodePath \
		setget set_slider_focus_right, get_slider_focus_right

## The slider's focus neighbour to the bottom.
export(NodePath) var slider_focus_bottom: NodePath \
		setget set_slider_focus_bottom, get_slider_focus_bottom

## The slider's next focus target.
export(NodePath) var slider_focus_next: NodePath \
		setget set_slider_focus_next, get_slider_focus_next

## The slider's previous focus target.
export(NodePath) var slider_focus_previous: NodePath \
		setget set_slider_focus_previous, get_slider_focus_previous


# The slider control itself.
var _slider: HSlider = null

# The label which displays the value of the slider.
var _label: Label = null


func _init():
	# Since the root node is just a container, have it ignore all mouse events
	# and pass them onto the slider directly. This makes sure that only the
	# slider is emitting the mouse_entered and mouse_exited events.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_slider = HSlider.new()
	_slider.min_value = min_value
	_slider.max_value = max_value
	_slider.step = step
	_slider.value = value
	_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_slider.connect("value_changed", self, "_on_value_changed")
	
	# Forward the focus and mouse signals from the slider to the outside world.
	_slider.connect("focus_entered", self, "_on_focus_entered")
	_slider.connect("focus_exited", self, "_on_focus_exited")
	_slider.connect("mouse_entered", self, "_on_mouse_entered")
	_slider.connect("mouse_exited", self, "_on_mouse_exited")
	add_child(_slider)
	
	_label = Label.new()
	_label.clip_text = true
	_label.rect_min_size = Vector2(display_width, 0.0)
	if font_override != null:
		_label.add_font_override("font", font_override)
	add_child(_label)
	
	update_label()


## Update the label to display the slider's current value.
func update_label() -> void:
	if _slider == null or _label == null:
		return
	
	var current_value := display_scalar * _slider.value
	var value_as_text := ""
	
	if display_percentage:
		value_as_text = "%.0f%%" % (100.0 * current_value)
	elif display_integer:
		value_as_text = "%.0f" % current_value
	else:
		value_as_text = "%.1f" % current_value
	
	_label.text = prefix + value_as_text + suffix


func get_min_value() -> float:
	if _slider == null:
		return 0.0
	
	return _slider.min_value


func get_max_value() -> float:
	if _slider == null:
		return 0.0
	
	return _slider.max_value


func get_step() -> float:
	if _slider == null:
		return 0.0
	
	return _slider.step


func get_value() -> float:
	if _slider == null:
		return 0.0
	
	return _slider.value


func get_display_width() -> float:
	if _label == null:
		return 0.0
	
	return _label.rect_min_size.x


func get_font_override() -> Font:
	if _label == null:
		return null
	
	if not _label.has_font_override("font"):
		return null
	
	return _label.get_font("font")


func get_slider_focus_left() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_neighbour_left
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func get_slider_focus_top() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_neighbour_top
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func get_slider_focus_right() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_neighbour_right
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func get_slider_focus_bottom() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_neighbour_bottom
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func get_slider_focus_next() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_next
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func get_slider_focus_previous() -> NodePath:
	if _slider == null:
		return NodePath()
	
	var slider_path := _slider.focus_previous
	if slider_path.is_empty():
		return NodePath()
	
	# Remove the "../" prefix.
	var path := String(slider_path).substr(3)
	return NodePath(path)


func set_min_value(new_value: float) -> void:
	if _slider == null:
		return
	
	_slider.min_value = new_value


func set_max_value(new_value: float) -> void:
	if _slider == null:
		return
	
	_slider.max_value = new_value


func set_step(new_value: float) -> void:
	if _slider == null:
		return
	
	_slider.step = new_value


func set_value(new_value: float) -> void:
	if _slider == null:
		return
	
	_slider.value = new_value
	update_label()


func set_prefix(new_value: String) -> void:
	prefix = new_value
	update_label()


func set_suffix(new_value: String) -> void:
	suffix = new_value
	update_label()


func set_display_integer(new_value: bool) -> void:
	display_integer = new_value
	update_label()


func set_display_percentage(new_value: bool) -> void:
	display_percentage = new_value
	update_label()


func set_display_scalar(new_value: float) -> void:
	display_scalar = new_value
	update_label()


func set_display_width(new_value: float) -> void:
	if _label == null:
		return
	
	_label.rect_min_size.x = new_value


func set_font_override(new_font: Font) -> void:
	if _label == null:
		return
	
	_label.add_font_override("font", new_font)


func set_slider_focus_left(neighbour: NodePath) -> void:
	if _slider == null:
		return
	
	if neighbour.is_empty():
		_slider.focus_neighbour_left = NodePath()
		return
	
	var path := String(neighbour)
	_slider.focus_neighbour_left = "..".plus_file(path)


func set_slider_focus_top(neighbour: NodePath) -> void:
	if _slider == null:
		return
	
	if neighbour.is_empty():
		_slider.focus_neighbour_top = NodePath()
		return
	
	var path := String(neighbour)
	_slider.focus_neighbour_top = "..".plus_file(path)


func set_slider_focus_right(neighbour: NodePath) -> void:
	if _slider == null:
		return
	
	if neighbour.is_empty():
		_slider.focus_neighbour_right = NodePath()
		return
	
	var path := String(neighbour)
	_slider.focus_neighbour_right = "..".plus_file(path)


func set_slider_focus_bottom(neighbour: NodePath) -> void:
	if _slider == null:
		return
	
	if neighbour.is_empty():
		_slider.focus_neighbour_bottom = NodePath()
		return
	
	var path := String(neighbour)
	_slider.focus_neighbour_bottom = "..".plus_file(path)


func set_slider_focus_next(next: NodePath) -> void:
	if _slider == null:
		return
	
	if next.is_empty():
		_slider.focus_next = NodePath()
		return
	
	var path := String(next)
	_slider.focus_next = "..".plus_file(path)


func set_slider_focus_previous(previous: NodePath) -> void:
	if _slider == null:
		return
	
	if previous.is_empty():
		_slider.focus_previous = NodePath()
		return
	
	var path := String(previous)
	_slider.focus_previous = "..".plus_file(path)


func _on_value_changed(new_value: float) -> void:
	update_label()
	emit_signal("value_changed", new_value)


func _on_focus_entered() -> void:
	emit_signal("focus_entered")


func _on_focus_exited() -> void:
	emit_signal("focus_exited")


func _on_mouse_entered() -> void:
	emit_signal("mouse_entered")


func _on_mouse_exited() -> void:
	emit_signal("mouse_exited")