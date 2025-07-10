## String Wrangler Plugin
## Created by Matthew Janes (IndieGameDad) - 2025

## Registry resource for string-based prefix handlers used by custom editor dropdowns.
## Provides label, dataset, and visibility rules for prefix-based field types.
@tool class_name StringPrefixRegistry extends Resource

@export var prefix_handlers: Dictionary = {}


func _init() -> void:
	add_handler("SWSamp_", "Sample String List", true, false, "raw_array", ["A", "B", "C", "D", "A", "B", "C", "D"])
	add_handler("SWSampD_", "Sample String List", true, true, "raw_array", ["A", "B", "C", "D", "A", "B", "C", "D"])
	#add_handler(ManaSystem.VARIABLE_PREFIX_TAG, "ManaTag List", true, "sourced_array", [], "Function", ManaSystem.get_mana_tag_registry(), "get_all_flat_names")


## Adds a new prefix handler entry to the registry.
## Safely inserts all required fields with defaults for unused properties.
## Will not override existing entries.
func add_handler(prefix: String, label: String, show_none: bool, allow_duplicates: bool, source_type: String, raw_values: Array[String] = [] as Array[String], call_type: String = "", script_resource: Resource = null, call_name: String = "") -> void:
	if prefix_handlers.has(prefix):
		return
	
	prefix_handlers[prefix] = {
		"label": label,
		"show_none": show_none,
		"allow_duplicates": allow_duplicates,
		"source_type": source_type,
		"raw_values": raw_values,
		"source": {
			"type": call_type,
			"script_resource": script_resource,
			"call_name": call_name
		}
	}


## Checks if a prefix has a registered handler.
func has(prefix: String) -> bool:
	return prefix_handlers.has(prefix)


## Returns the string label for the given prefix, or default fallback.
func get_label(prefix: String) -> String:
	if not has(prefix):
		return "StringList"
	var handler: Dictionary = prefix_handlers[prefix]
	return handler.get("label", "StringList")

## Returns whether you want your dropdowns to include duplicate selection and/or options
func get_allow_duplicates(prefix: String) -> bool:
	if not has(prefix):
		return false
	var handler: Dictionary = prefix_handlers[prefix]
	return handler.get("allow_duplicates", false)


## Returns whether to show a "(None)" entry in dropdowns.
func get_show_none(prefix: String) -> bool:
	if not has(prefix):
		return true
	var handler: Dictionary = prefix_handlers[prefix]
	return handler.get("show_none", true)


## Returns the list of strings for the given prefix using the defined source.
## Supports raw arrays and dynamically sourced arrays (via function or variable).
func get_dataset(prefix: String) -> Array[String]:
	var return_array: Array[String] = [] as Array[String]
	
	if not has(prefix):
		return return_array
	
	var handler: Dictionary = prefix_handlers[prefix]
	var source_type: String = handler.get("source_type", "")
	
	match source_type:
		"raw_array":
			var raw_values: Array[String] = handler.get("raw_values", []) as Array[String]
			return_array = raw_values
		
		"sourced_array":
			var source: Dictionary = handler.get("source", {})
			var script: Object = source.get("script_resource", null)
			var call_name: String = source.get("call_name", "")
			var call_type: String = source.get("type", "")
			
			if script == null or call_name == "":
				return return_array
			
			match call_type:
				"Function":
					if script.has_method(call_name):
						var result := script.call(call_name)
						if result is Array and result.all(func(x): return typeof(x) == TYPE_STRING):
							var func_values: Array[String] = result as Array[String]
							return_array = func_values

				"Variable":
					if script.has_property(call_name):
						var value := script.get(call_name)
						if value is Array and value.all(func(x): return typeof(x) == TYPE_STRING):
							var vari_values: Array[String] = value as Array[String]
							return_array = vari_values
		
		_:
			# Unknown type fallback
			return get_filtered_array(return_array)
	
	return get_filtered_array(return_array)


## Returns a new array with all duplicate strings removed.
## Used to enforce unique-only dropdown values when allow_duplicates is false.
func get_filtered_array(array: Array[String]) -> Array[String]:
	if array.is_empty():
		return [] as Array[String]
		
	var unique_strings: Array[String] = []
	
	for string in array:
		if not unique_strings.has(string):
			unique_strings.append(string)
	
	return unique_strings as Array[String]
