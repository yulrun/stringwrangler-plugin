## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Visual Editor UI/UX Popup for StringWrangler Add/Edit Functionality
@tool class_name SWPopupWindow extends AcceptDialog

var is_edit_mode: bool = false
var edit_prefix_name: String = ""

var prefix_registry: StringPrefixRegistry
var raw_values: Array[String] = [] as Array[String]

var prefix_warning: String = ""
var file_path_warning: String = ""
var source_type_name_warning: String = ""

@onready var info_panel_container: PanelContainer = %InfoPanelContainer
@onready var info_label: Label = %InfoLabel
@onready var prefix_name_line_edit: LineEdit = %PrefixNameLineEdit
@onready var description_text_edit: TextEdit = %DescriptionTextEdit
@onready var label_name_line_edit: LineEdit = %LabelNameLineEdit
@onready var show_none_check_button: CheckButton = %ShowNoneCheckButton
@onready var include_duplicates_check_button: CheckButton = %IncludeDuplicatesCheckButton
@onready var source_path_line_edit: LineEdit = %SourcePathLineEdit
@onready var source_type_option_button: OptionButton = %SourceTypeOptionButton
@onready var call_type_line_edit: LineEdit = %CallTypeLineEdit


func _ready() -> void:
	_initialize_scene()
	_initialize_connections()


## Initialize scene variables and data
func _initialize_scene() -> void:
	prefix_registry = StringWrangler.get_prefix_registry()
	_validate_confirmation_possible()
	info_panel_container.self_modulate = get_theme_color("accent_color", "Editor")
	
	# Janky but required to clamp size on startup do to execusion order
	show()
	reset_size()
	call_deferred("hide")


## Initialize any signal connections to related function calls
func _initialize_connections() -> void:
	prefix_name_line_edit.text_changed.connect(func(text: String): _validate_confirmation_possible())
	source_path_line_edit.text_changed.connect(func(text: String): _validate_confirmation_possible())
	call_type_line_edit.text_changed.connect(func(text: String): _validate_confirmation_possible())
	source_type_option_button.item_selected.connect(_on_source_type_selected)
	visibility_changed.connect(func(): call_deferred("reset_size"))


## Resets all the data entry points on the popup window
func clear() -> void:
	prefix_warning = ""
	file_path_warning = ""
	source_type_name_warning = ""

	edit_prefix_name = ""
	
	prefix_name_line_edit.text = ""
	description_text_edit.text = ""
	
	label_name_line_edit.text = ""
	show_none_check_button.button_pressed = false
	include_duplicates_check_button.button_pressed = false
	
	source_path_line_edit.text = ""
	source_type_option_button.select(0)
	call_type_line_edit.text = ""


## Opens the window with a fresh Clear() and ready for input for new entry
func open_for_create() -> void:
	is_edit_mode = false
	get_ok_button().disabled = true
	clear()
	
	title = "StringWrangler: Create Prefix Handler"
	popup_centered()
	prefix_name_line_edit.grab_focus()
	call_deferred("reset_size")
	_validate_confirmation_possible()


## Opens the window for a specific registry prefix, with data pre-populated
func open_for_edit(prefix: String) -> void:
	is_edit_mode = true
	get_ok_button().disabled = true
	clear()
	
	edit_prefix_name = prefix
	
	# Initialize all values
	var data_set: Dictionary = prefix_registry.prefix_handlers[prefix]
	prefix_name_line_edit.text = prefix.trim_suffix("_")
	label_name_line_edit.text =  data_set.label
	show_none_check_button.button_pressed = data_set.show_none
	include_duplicates_check_button.button_pressed = data_set.allow_duplicates
	source_type_option_button.select(0 if data_set.source.type == "Function" else 1)
	source_type_option_button.item_selected.emit(0 if data_set.source.type == "Function" else 1)
	source_path_line_edit.text = data_set.source.script_resource.resource_path if data_set.source.script_resource != null else ""
	call_type_line_edit.text = data_set.source.call_name
	
	title = "StringWrangler: Edit Prefix Handler %s" % prefix
	popup_centered()
	prefix_name_line_edit.grab_focus()
	call_deferred("reset_size")
	_validate_confirmation_possible()


## Updates the line edit placeholder, and calls for a new validation check
func _on_source_type_selected(index: int) -> void:
	if index == 0:
		call_type_line_edit.placeholder_text = "Function Name"
	elif index == 1:
		call_type_line_edit.placeholder_text = "Variable Name"
	else:
		call_type_line_edit.placeholder_text = ""
	
	_validate_confirmation_possible()


## Determines if the create button is enabled or disabled through validation checks
func _validate_confirmation_possible() -> void:
	var name_is_valid: bool = _validate_prefix_name()
	var file_path_is_valid: bool = _validate_file_path()
	var source_type_name_is_valid: bool = _validate_source_type_name()
	
	var valid: bool = name_is_valid and file_path_is_valid and source_type_name_is_valid
	
	get_ok_button().tooltip_text = prefix_warning + file_path_warning + source_type_name_warning
	
	if valid:
		get_ok_button().disabled = false
	else:
		get_ok_button().disabled = true
	
	reset_size()


## Validates the prefix name
func _validate_prefix_name() -> bool:
	var prefix_name: String = prefix_name_line_edit.text
	
	if prefix_name.strip_edges().is_empty():
		prefix_warning = "> Prefix Name cannot be blank!\n"
		return false
	
	var regex: RegEx = RegEx.new()
	regex.compile("^[a-zA-Z]+$")
	if not regex.search(prefix_name):
		prefix_warning = "> Prefix Name must only contain letters, and cannot be blank!\n"
		return false
	
	if prefix_registry.has(prefix_name + "_"):
		if not is_edit_mode:
			prefix_warning = "> Prefix Name already exists!\n"
			return false
		elif prefix_name != edit_prefix_name.trim_suffix("_"):
			prefix_warning = "> Prefix Name already exists!\n"
			return false
	
	prefix_warning = ""
	return true


## Validates the file path
func _validate_file_path() -> bool:
	var file_path: String = source_path_line_edit.text
	
	if file_path.strip_edges().is_empty():
		file_path_warning = "> Source File path cannot be empty!\n"
		return false
	
	if not FileAccess.file_exists(file_path):
		file_path_warning = "> File does not exists!\n"
		return false
	
	file_path_warning = ""
	return true


# Validates the source type name
func _validate_source_type_name() -> bool:
	if not _validate_file_path():
		source_type_name_warning = "> Can't Check Func/Variable name, source doesn't exist.\n"
		return false
	
	var access_name: String = source_path_line_edit.text
	var source_object := load(access_name)
	var instance: Variant = source_object
	if source_object is Script and source_object.can_instantiate():
		instance = source_object.new()
	
	var call_name: String = call_type_line_edit.text
	
	match source_type_option_button.selected:
		0: # Function
			if not instance.has_method(call_name):
				source_type_name_warning = "> Return function doesn't exist"
				return false
				
			var result = instance.call(call_name)
			if not result is Array and result.all(func(x): return typeof(x) == TYPE_STRING):
				source_type_name_warning = "> Return function has wrong return type..."
				return false
			
		1: # Variable
			if instance.get(call_name) == null:
				source_type_name_warning = "> Cannot find variable.."
				return false
	
	source_type_name_warning = ""
	return true
