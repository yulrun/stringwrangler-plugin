## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Visual Editor UI/UX Panel for StringWrangler
@tool class_name StringWranglerManagerPanel extends VBoxContainer


var _keep_tree_collapsed: bool = true

@onready var add_button: Button = %AddButton
@onready var filter_bar: LineEdit = %FilterBar
@onready var expand_collapse_button: Button = %ExpandCollapseButton


func _ready() -> void:
	add_button.icon = get_theme_icon("Add", "EditorIcons")
	add_button.tooltip_text = "Add Prefix Handler"
	filter_bar.right_icon = get_theme_icon("Search", "EditorIcons")
	filter_bar.tooltip_text = "Filter Prefix's"
	filter_bar.placeholder_text = "Filter Prefix's"
	_set_expand_collapse_button_icon_and_tooltip()


## @Description: Updates icon and tooltip for the Expand/Collapse button.
func _set_expand_collapse_button_icon_and_tooltip() -> void:
	if _keep_tree_collapsed:
		expand_collapse_button.icon = get_theme_icon("ExpandTree", "EditorIcons")
		expand_collapse_button.tooltip_text = "Expand All Effects"
	else:
		expand_collapse_button.icon = get_theme_icon("CollapseTree", "EditorIcons")
		expand_collapse_button.tooltip_text = "Collapse All Effects"
