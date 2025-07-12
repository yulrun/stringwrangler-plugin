## String Wrangler
## Created by Matthew Janes (IndieGameDad) - 2025

## A sample source of data for viewing
@tool class_name StringWranglerSample extends Node

## Sample Simple Array
var sample_array: Array[String] = ["Value A", "Value B", "Value C", "Value D", "Value A", "Value B", "Value C", "Value D"]

## Sample Dataset
var sample_dataset: Dictionary = {
	"Key A": {
		value = 0,
		other_value = "Something 1"
	},
	"Key B": {
		value = 0,
		other_value = "Something 2"
	},
	"Key C": {
		value = 0,
		other_value = "Something 3"
	},
	"Key D": {
		value = 0,
		other_value = "Something 4"
	},
}


## Sample function using a straight keyset return
func sample_function_a() -> Array[String]:
	var array: Array[String] = [] as Array[String]
	
	for key in sample_dataset.keys():
		if not array.has(key):
			array.append(key)
	
	return array as Array[String]


## Sample funciton using a dataset dive for deeper data values
func sample_function_b() -> Array[String]:
	var array: Array[String] = [] as Array[String]
	
	for key in sample_dataset.keys():
		var new_value: String = sample_dataset[key].other_value
		if not array.has(new_value):
			array.append(new_value)
	
	return array as Array[String]
