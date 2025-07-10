## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Main plugin class responsible for managing string-based editor enhancements.
## Registers custom editor inspectors, prefix handlers, and UI tools.
@tool class_name StringWrangler extends EditorPlugin


const PREFIX_REGISTRY_PATH: String = "res://addons/string_wrangler/data/prefix_registry.tres"

var control: Control
var string_suffix_handler_plugin: StringPrefixHandler

func _enter_tree() -> void:
	string_suffix_handler_plugin = StringPrefixHandler.new()
	add_inspector_plugin(string_suffix_handler_plugin)
	
	control = Control.new()
	control.name = "StringWrangler"
	control.visible = true
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, control)


func _exit_tree() -> void:
	if string_suffix_handler_plugin:
		remove_inspector_plugin(string_suffix_handler_plugin)
		
	remove_control_from_docks(control)


static func get_prefix_registry(cache_mode: ResourceLoader.CacheMode = 1) -> StringPrefixRegistry: 
	return ResourceLoader.load(PREFIX_REGISTRY_PATH, "Resource", cache_mode)
