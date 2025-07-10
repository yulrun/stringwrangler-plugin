## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## A generic editor property for selecting multiple string options.
## Dynamically disables already-selected entries and supports clean UI expansion.
@tool class_name MultiOptionEditorProperty extends EditorProperty

var available_options: Array[String] = []
var selected_options: Array[String] = []

var is_expanded: bool = false
var _refreshing: bool = false

var fold_button: Button
var container: VBoxContainer
var main_container: VBoxContainer

var list_display_name: String = ""

var include_duplicates: bool = false


## Initializes the editor with a list of selectable values and currently selected items.
## Called by the StringPrefixHandler to setup multi-value dropdown UI.
func initialize(initial_values: Array[String], options: Array[String], list_name: String = "StringList", allow_duplicates: bool = false) -> void:
	available_options = options.duplicate()
	selected_options.clear()
	
	list_display_name = list_name
	include_duplicates = allow_duplicates
	
	for item in initial_values:
		if available_options.has(item):
			selected_options.append(item)
	
	_setup_ui()
	call_deferred("_refresh")


## Creates and adds the fold button and container layout.
## The fold button toggles visibility of the dropdown list.
func _setup_ui() -> void:
	main_container = VBoxContainer.new()
	main_container.custom_minimum_size = Vector2(0, 48)
	add_child(main_container)
	
	fold_button = Button.new()
	fold_button.toggle_mode = true
	fold_button.focus_mode = Control.FOCUS_NONE
	fold_button.set_pressed_no_signal(is_expanded)
	fold_button.toggled.connect(_on_fold_button_toggled)
	_update_fold_button_text()
	
	main_container.add_child(fold_button)
	
	container = VBoxContainer.new()
	container.visible = is_expanded
	main_container.add_child(container)


## Called when the fold toggle is pressed to show/hide tag rows.
## Updates the visibility of the dropdown container and button label.
func _on_fold_button_toggled(pressed: bool) -> void:
	is_expanded = pressed
	container.visible = pressed
	_update_fold_button_text()


## Updates the fold button text to include current selected item count.
## Example: "StringList (3)"
func _update_fold_button_text() -> void:
	fold_button.text = "%s (%d)" % [list_display_name, selected_options.size()]


## Rebuilds all dropdown rows and updates Add button.
## Called during initialization or when values change.
func _refresh() -> void:
	if _refreshing:
		return
	_refreshing = true
	
	# Remove all children from container
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
	
	for i in range(selected_options.size()):
		_build_row(i)
	
	var add_button: Button = Button.new()
	add_button.icon = get_theme_icon("Add", "EditorIcons")
	add_button.text = "Add Item"
	add_button.focus_mode = Control.FOCUS_NONE
	add_button.disabled = _get_unused_options().is_empty()
	add_button.pressed.connect(_on_add_pressed)
	container.add_child(add_button)
	
	call_deferred("_update_property")
	_update_fold_button_text()
	_refreshing = false


## Builds a single dropdown row at the specified index.
## Each row includes a dropdown for item selection and a remove button.
func _build_row(index: int) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	
	var dropdown: OptionButton = OptionButton.new()
	dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var used: Array[String] = selected_options.duplicate()
	used.remove_at(index)
	
	for option in available_options:
		var idx: int = dropdown.item_count
		dropdown.add_item(option)
		if not include_duplicates and used.has(option):
			dropdown.set_item_disabled(idx, true)
	
	var current_index: int = available_options.find(selected_options[index])
	if current_index >= 0:
		dropdown.select(current_index)
	
	dropdown.item_selected.connect(func(i: int) -> void:
		var selected: String = available_options[i]
		if selected in selected_options and selected_options[index] != selected:
			dropdown.select(available_options.find(selected_options[index]))
			return
		selected_options[index] = selected
		_emit_changed()
		call_deferred("_refresh")
	)
	
	var remove: Button = Button.new()
	remove.icon = get_theme_icon("Remove", "EditorIcons")
	remove.tooltip_text = "Remove Item"
	remove.focus_mode = Control.FOCUS_NONE
	remove.pressed.connect(func() -> void:
		selected_options.remove_at(index)
		_emit_changed()
		call_deferred("_refresh")
	)
	
	row.add_child(dropdown)
	row.add_child(remove)
	container.add_child(row)


## Emits the updated list of selected options to the inspector.
## Used to serialize the current dropdown values to the target resource.
func _emit_changed() -> void:
	emit_changed(get_edited_property(), selected_options.duplicate())


## Adds the first unused option to the list and refreshes the editor.
## Called when the Add button is pressed.
func _on_add_pressed() -> void:
	var unused: Array[String] = _get_unused_options()
	if not unused.is_empty():
		selected_options.append(unused[0])
		_emit_changed()
		call_deferred("_refresh")


## Returns a list of options that have not yet been selected.
## Used to prevent duplicates and disable Add button when all are used.
func _get_unused_options() -> Array[String]:
	if include_duplicates:
		return available_options
		
	var result: Array[String] = []
	for item in available_options:
		if not selected_options.has(item):
			result.append(item)
	return result


## Called when external values change or the editor is reloaded.
## Ensures the selected options match the underlying array property.
func _update_property() -> void:
	var raw = get_edited_object().get(get_edited_property())
	if raw == null or not raw is Array:
		return
	
	for item in raw:
		if typeof(item) != TYPE_STRING:
			return
	
	if selected_options != raw:
		selected_options = raw.duplicate()
		call_deferred("_refresh")
