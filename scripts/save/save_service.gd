extends RefCounted

const SAVE_PATH := "user://tycoon_save.json"

static func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"coins": 0.0, "speed": 0.0, "placed": [], "rebirths": 0}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	return parsed if parsed is Dictionary else {"coins": 0.0, "speed": 0.0, "placed": [], "rebirths": 0}

static func save_data(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true
