## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Main plugin class responsible for managing string-based editor enhancements.
## Registers custom editor inspectors, prefix handlers, and UI tools.
@tool class_name StringWrangler extends EditorPlugin


const PREFIX_REGISTRY_PATH: String = "res://addons/string_wrangler/data/prefix_registry.tres"
const MASTER_PANEL_CONTROL_SCENE: PackedScene = preload("res://addons/string_wrangler/ui/string_wrangler_manager_panel.tscn")

var master_panel_control_instance: Control
var string_suffix_handler_plugin: StringPrefixHandler

func _enter_tree() -> void:
	string_suffix_handler_plugin = StringPrefixHandler.new()
	add_inspector_plugin(string_suffix_handler_plugin)
	
	master_panel_control_instance = MASTER_PANEL_CONTROL_SCENE.instantiate()
	master_panel_control_instance.name = "StringWrangler"
	master_panel_control_instance.visible = true
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, master_panel_control_instance)


func _exit_tree() -> void:
	if string_suffix_handler_plugin:
		remove_inspector_plugin(string_suffix_handler_plugin)
		
	remove_control_from_docks(master_panel_control_instance)


static func get_prefix_registry(cache_mode: ResourceLoader.CacheMode = 1) -> StringPrefixRegistry: 
	return ResourceLoader.load(PREFIX_REGISTRY_PATH, "Resource", cache_mode)
