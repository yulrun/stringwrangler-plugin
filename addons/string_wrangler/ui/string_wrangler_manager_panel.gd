## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Visual Editor UI/UX Panel for StringWrangler
@tool class_name StringWranglerManagerPanel extends VBoxContainer


const COLUMN_MAIN: int = 0
const COLUMN_EDIT: int = 1
const COLUMN_DELETE: int = 2

var pending_delete_prefix: String = ""
var _keep_tree_collapsed: bool = true

var edit_icon: Texture2D
var delete_icon: Texture2D
var delete_dialog: AcceptDialog

var prefix_registry: StringPrefixRegistry

@onready var info_label: Label = %InfoLabel
@onready var add_button: Button = %AddButton
@onready var filter_bar: LineEdit = %FilterBar
@onready var expand_collapse_button: Button = %ExpandCollapseButton
@onready var tree: Tree = %Tree
@onready var popup_window: SWPopupWindow = %PopupWindow


func _ready() -> void:
	_initialize_scene()
	_initialize_signal_connections()
	_initialize_tree_data()
	_refresh()


## @Description: Sets up UI icons, tooltips, and column headers.
func _initialize_scene() -> void:
	info_label.set("theme_override_font_sizes/font_size", get_theme_font_size("Editor") - 4)
	add_button.icon = get_theme_icon("Add", "EditorIcons")
	add_button.tooltip_text = "Add Prefix Handler"
	filter_bar.right_icon = get_theme_icon("Search", "EditorIcons")
	filter_bar.tooltip_text = "Filter Prefix's"
	filter_bar.placeholder_text = "Filter Prefix's"
	
	edit_icon = get_theme_icon("Edit", "EditorIcons")
	delete_icon = get_theme_icon("Remove", "EditorIcons")
	
	_set_expand_collapse_button_icon_and_tooltip()
	
	tree.hide_root = true
	tree.columns = 3
	tree.set_column_expand(COLUMN_MAIN, true)
	tree.set_column_expand(COLUMN_EDIT, false)
	tree.set_column_expand(COLUMN_DELETE, false)
	
	_create_delete_dialog()
	popup_window.reset_size()


## @Description: Connects UI signals to their respective handlers.
func _initialize_signal_connections() -> void:
	add_button.pressed.connect(_on_add_button_pressed)
	expand_collapse_button.pressed.connect(_on_expand_collapse_button_pressed)
	filter_bar.text_changed.connect(_on_filter_text_changed)
	tree.cell_selected.connect(_on_tree_cell_selected)
	popup_window.canceled.connect(_on_popup_cancelled)
	popup_window.confirmed.connect(_on_popup_confirmed)


## @Description: Loads or creates the prefix registry and prepares tree data.
func _initialize_tree_data() -> void:
	if not ResourceLoader.exists(StringWrangler.PREFIX_REGISTRY_PATH):
		prefix_registry = StringPrefixRegistry.new()
		ResourceSaver.save(prefix_registry, StringWrangler.PREFIX_REGISTRY_PATH)
	else:
		prefix_registry = StringWrangler.get_prefix_registry()
	
	assert(prefix_registry != null)


## @Description: Rebuilds the list of effects in the tree.
func _refresh() -> void:
	tree.clear()
	
	var root: TreeItem = tree.create_item()
	
	var prefixes: Array[String] = prefix_registry.get_handlers()
	
	var filtered_prefixes: Array[String]
	var filter_bar_text: String = filter_bar.text.strip_edges().to_lower()
	
	if not filter_bar_text.is_empty():
		for prefix in prefixes:
			if prefix.to_lower().contains(filter_bar_text):
				filtered_prefixes.append(prefix)
	else:
		filtered_prefixes = prefixes
	
	filtered_prefixes.sort()
	
	for index in range(filtered_prefixes.size()):
		var item: TreeItem = tree.create_item(root)
		var prefix_name: String = prefixes[index]
		var description: String = prefix_registry.prefix_handlers[prefix_name].get("description", "No Description")
		
		var display_name: String = ""
		if prefix_name.ends_with("_"):
			display_name = prefix_name.trim_suffix("_")
		else:
			display_name = prefix_name
		
		item.set_metadata(COLUMN_MAIN, prefix_name)
		item.set_text(COLUMN_MAIN, display_name)
		item.set_tooltip_text(COLUMN_MAIN, description)
		item.set_custom_font_size(COLUMN_MAIN, get_theme_font_size("Editor"))
		item.set_icon(COLUMN_EDIT, edit_icon)
		item.set_icon(COLUMN_DELETE, delete_icon)
		item.set_tooltip_text(COLUMN_EDIT, "Edit %s" % prefix_name)
		item.set_tooltip_text(COLUMN_DELETE, "Delete %s" % prefix_name)
		
		_set_prefix_icon(item, prefix_name)
		#_add_child_tree_item_info(item, prefix_name)
		
		if _keep_tree_collapsed:
			item.collapsed = true


## @Description: Adds child rows with key wrangler properties for quick viewing.
func _add_child_tree_item_info(parent: TreeItem, prefix: String) -> void:
	var description: String = prefix_registry.prefix_handlers[prefix].get("description", "No Description")
	var item: TreeItem = tree.create_item(parent)
	
	item.set_text(COLUMN_MAIN, description)


func _set_prefix_icon(item: TreeItem, prefix: String) -> void:
	var data_set: Dictionary = prefix_registry.prefix_handlers[prefix]
	var source: Dictionary = data_set.get("source", {})
	var call_type: String = source.get("type", "")
	
	match call_type:
		"Function":
			var color = Color.MEDIUM_ORCHID
			item.set_icon(COLUMN_MAIN, get_theme_icon("VisualShaderNodeIntFunc", "EditorIcons"))
			item.set_custom_color(COLUMN_MAIN, color)
		"Variable": 
			var color = Color.AQUAMARINE
			item.set_icon(COLUMN_MAIN, get_theme_icon("LocalVariable", "EditorIcons"))
			item.set_custom_color(COLUMN_MAIN, color)
			item.set_icon_modulate(COLUMN_MAIN, color)


## @Description: Creates the in-code AcceptDialog used for effect deletion.
func _create_delete_dialog() -> void:
	delete_dialog = AcceptDialog.new()
	delete_dialog.title = "Confirm Deletion"
	delete_dialog.dialog_text = "Are you sure you want to delete this effect?"
	delete_dialog.get_ok_button().text = "Delete"
	delete_dialog.confirmed.connect(_on_delete_confirmed)
	delete_dialog.canceled.connect(_on_popup_cancelled)
	add_child(delete_dialog)


## @Description: Updates icon and tooltip for the Expand/Collapse button.
func _set_expand_collapse_button_icon_and_tooltip() -> void:
	if _keep_tree_collapsed:
		expand_collapse_button.icon = get_theme_icon("ExpandTree", "EditorIcons")
		expand_collapse_button.tooltip_text = "Expand All Tree Elements"
	else:
		expand_collapse_button.icon = get_theme_icon("CollapseTree", "EditorIcons")
		expand_collapse_button.tooltip_text = "Collapse All Tree Elements"


## @Description: Handles logic when a tree cell is selected (edit/delete).
func _on_tree_cell_selected() -> void:
	var selected: TreeItem = tree.get_selected()
	if not selected:
		return
	
	var column: int = tree.get_selected_column()
	var prefix: String = selected.get_metadata(COLUMN_MAIN)
	
	match column:
		COLUMN_EDIT:
			if prefix_registry.has(prefix):
				popup_window.open_for_edit(prefix)
		
		COLUMN_DELETE:
			if prefix_registry.has(prefix):
				pending_delete_prefix = prefix
				delete_dialog.dialog_text = "Are you sure you want to delete \"%s\"?" % prefix
				delete_dialog.popup_centered()


## @Description: Handles filtering when user types in the filter bar.
func _on_filter_text_changed(new_text: String) -> void:
	_refresh()


## @Description: Opens the popup to create a new effect.
func _on_add_button_pressed() -> void:
	popup_window.open_for_create()


## @Description: Confirms deletion of a selected prefix handler from the registry.
func _on_delete_confirmed() -> void:
	if prefix_registry.has(pending_delete_prefix):
		prefix_registry.remove_handler(pending_delete_prefix)
		_refresh()
		pending_delete_prefix = ""


## @Description: Cancels deletion or popup edit and refreshes.
func _on_popup_confirmed() -> void:
	var was_edit_mode: bool = popup_window.is_edit_mode
	var prefix_name: String = popup_window.prefix_name_line_edit.text + "_"
	var label: String = popup_window.label_name_line_edit.text
	var show_none: bool = popup_window.show_none_check_button.button_pressed
	var allow_duplicates: bool = popup_window.include_duplicates_check_button.button_pressed
	var call_type: String = popup_window.source_type_option_button.get_item_text(popup_window.source_type_option_button.selected)
	var script: Variant = load(popup_window.source_path_line_edit.text) if FileAccess.file_exists(popup_window.source_path_line_edit.text) else null
	var call_name: String = popup_window.call_type_line_edit.text
	var description: String = popup_window.description_text_edit.text
	
	match was_edit_mode:
		true:
			prefix_registry.remove_handler(popup_window.edit_prefix_name)
			prefix_registry.add_handler(prefix_name, label, show_none, allow_duplicates, call_type, script, call_name, description)
		false:
			prefix_registry.add_handler(prefix_name, label, show_none, allow_duplicates, call_type, script, call_name, description)
	ResourceSaver.save(prefix_registry)
	_refresh()


## @Description: Cancels deletion or popup edit and refreshes.
func _on_popup_cancelled() -> void:
	_refresh()


## @Description: Handles expanding and collapsing the tree list of effects.
func _on_expand_collapse_button_pressed() -> void:
	_keep_tree_collapsed = not _keep_tree_collapsed
	_set_expand_collapse_button_icon_and_tooltip()
	_refresh()
