extends Node

# Save System Singleton
class_name SaveManager

signal save_created(slot_name: String)
signal save_loaded(slot_name: String, data: Dictionary)
signal save_deleted(slot_name: String)
signal save_failed(slot_name: String, error: String)

const SAVE_DIR := "user://saves/"
const FILE_EXTENSION := ".save"

# Create or update a save slot
func save_game(data: Dictionary, slot_name: String) -> void:
	if slot_name.is_empty():
		_send_error("save_failed", slot_name, "Slot name cannot be empty")
		return
	
	var save_path := _get_save_path(slot_name)
	
	# Ensure save directory exists
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var error := FileAccess.get_open_error()
		_send_error("save_failed", slot_name, "Failed to open file: %d" % error)
		return
	
	# Add metadata
	var save_data := {
		"timestamp": Time.get_datetime_string_from_system(),
		"version": 1.0,
		"game_data": data
	}
	
	var json_string := JSON.stringify(save_data)
	file.store_line(json_string)
	file.close()
	
	print("Game saved successfully to slot: ", slot_name)
	save_created.emit(slot_name)

# Load data from a specific slot
func load_game(slot_name: String) -> Dictionary:
	if slot_name.is_empty():
		_send_error("save_failed", slot_name, "Slot name cannot be empty")
		return {}
	
	var save_path := _get_save_path(slot_name)
	
	if not FileAccess.file_exists(save_path):
		_send_error("save_failed", slot_name, "Save file does not exist")
		return {}
	
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		var error := FileAccess.get_open_error()
		_send_error("save_failed", slot_name, "Failed to open file: %d" % error)
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	
	if parse_result != OK:
		_send_error("save_failed", slot_name, "Failed to parse save data")
		return {}
	
	var save_data: Dictionary = json.data
	
	if not save_data.has("game_data"):
		_send_error("save_failed", slot_name, "Invalid save file format")
		return {}
	
	print("Game loaded successfully from slot: ", slot_name)
	save_loaded.emit(slot_name, save_data["game_data"])
	return save_data["game_data"]

# Delete a specific save slot
func delete_save(slot_name: String) -> void:
	var save_path := _get_save_path(slot_name)
	
	if FileAccess.file_exists(save_path):
		var error := DirAccess.remove_absolute(save_path)
		if error != OK:
			_send_error("save_failed", slot_name, "Failed to delete save file")
			return
		
		print("Save slot deleted: ", slot_name)
		save_deleted.emit(slot_name)
	else:
		_send_error("save_failed", slot_name, "Save file does not exist")

# Check if a save slot exists
func save_exists(slot_name: String) -> bool:
	return FileAccess.file_exists(_get_save_path(slot_name))

# Get all available save slots
func get_all_saves() -> Array[String]:
	var saves: Array[String] = []
	var dir := DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(FILE_EXTENSION):
				var slot_name := file_name.trim_suffix(FILE_EXTENSION)
				saves.append(slot_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return saves

# Get save metadata without loading full game data
func get_save_metadata(slot_name: String) -> Dictionary:
	if not save_exists(slot_name):
		return {}
	
	var save_path := _get_save_path(slot_name)
	var file := FileAccess.open(save_path, FileAccess.READ)
	
	if file == null:
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(json_string) != OK:
		return {}
	
	var save_data: Dictionary = json.data
	
	# Return only metadata, exclude game_data
	var metadata := {}
	if save_data.has("timestamp"):
		metadata["timestamp"] = save_data["timestamp"]
	if save_data.has("version"):
		metadata["version"] = save_data["version"]
	
	return metadata

# Helper function to get full file path
func _get_save_path(slot_name: String) -> String:
	return SAVE_DIR + slot_name + FILE_EXTENSION

# Helper function for error handling
func _send_error(signal_name: String, slot_name: String, error_message: String) -> void:
	push_error("Save Error [%s]: %s" % [slot_name, error_message])
	save_failed.emit(slot_name, error_message)
