## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## Inspector prefix handler for exposing tag dropdowns based on property name prefix.
## Supports single and multi-tag properties using MTag_ prefix for gameplay tags.
@tool class_name StringPrefixHandler extends EditorInspectorPlugin


### Determines if this suffix handler applies to the given object.
## Required for all EditorInspectorPlugin subclasses.
## Called by Godot editor internals.
func _can_handle(object: Object) -> bool:
	return true

## Parses each property and injects custom editor UI if suffix matches.
## Only applies to properties ending in _mana_taglist.
## Routes handling to internal logic for tag dropdowns.
func _parse_property(object: Object, type: Variant.Type, name: String, hint: PropertyHint, hint_text: String, usage: int, wide: bool) -> bool:
	var prefix: String = name.split("_")[0] + "_"

	if StringWrangler.get_prefix_registry().has(prefix):
		return _handle_prefixed_property(object, type, name, prefix)
	return false


## Builds tag editor widgets for string or array properties.
## Handles OptionButton or MultiTagEditorProperty creation.
## Applies cue filtering and dynamic label formatting.
func _handle_prefixed_property(object: Object, type: Variant.Type, name: String, prefix: String) -> bool:
	var clean_label: String = name.substr(prefix.length()).capitalize()
	
	var data_set: Array[String] = StringWrangler.get_prefix_registry().get_dataset(prefix)
	var list_name: String = StringWrangler.get_prefix_registry().get_label(prefix)
	var show_none: bool = StringWrangler.get_prefix_registry().get_show_none(prefix)
	var allow_duplicates: bool = StringWrangler.get_prefix_registry().get_allow_duplicates(prefix)
	
	match type:
		TYPE_STRING:
			var choices: Array[String] = data_set
			var current_value: String = object.get(name)
			var dropdown_data: Dictionary = _create_dropdown(choices, current_value, show_none)
			var editor: EditorProperty = EditorPropertyOptionWrapper.new(dropdown_data.dropdown, dropdown_data.show_none)
			add_property_editor(name, editor, false, clean_label)
			return true
		
		TYPE_ARRAY:
			var array_val = object.get(name)
			# Ensure all array values are Strings
			if array_val.all(func(x): return typeof(x) == TYPE_STRING):
				var editor: MultiOptionEditorProperty = MultiOptionEditorProperty.new()
				editor.initialize(array_val, data_set, list_name, allow_duplicates)
				add_property_editor(name, editor, false, clean_label)
				return true
	
	return false


## Creates a reusable dropdown selector from an array of strings.
## Supports optional 'None' entry and a callback for selection logic.
func _create_dropdown(choices: Array[String], current_value: String, show_none: bool) -> Dictionary:
	var dropdown: OptionButton = OptionButton.new()
	
	if show_none:
		dropdown.add_item("(None)")
	
	for choice in choices:
		dropdown.add_item(choice)
	
	var offset: int = 1 if show_none else 0
	var found_index: int = 0
	
	for i in range(offset, dropdown.item_count):
		if dropdown.get_item_text(i) == current_value:
			found_index = i
			break
	
	dropdown.select(found_index)
	
	return {
		"dropdown" = dropdown,
		"show_none" = show_none
	}
