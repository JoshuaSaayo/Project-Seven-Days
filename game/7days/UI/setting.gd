extends Control

#close button
@onready var close: Button = $Close

# button for changing tab
@onready var display: Button = $Display
@onready var audio: Button = $Audio

# tabs
@onready var audio_tab: Control = $AudioTab
@onready var display_tab: Control = $DisplayTab

# audio nodes
@onready var h_slider: HSlider = $AudioTab/Master/HSlider
@onready var h_slider_2: HSlider = $AudioTab/Music/HSlider2
@onready var h_slider_3: HSlider = $AudioTab/SFX/HSlider3
@onready var check_box: CheckBox = $AudioTab/Mute/CheckBox

# display nodes
@onready var check_box_windowed: CheckBox = $DisplayTab/Windowed/CheckBox
@onready var check_box_borderless: CheckBox = $DisplayTab/Borderless/CheckBox
@onready var check_box_fullscreen: CheckBox = $DisplayTab/Fullscreen/CheckBox
@onready var resolution: MenuButton = $DisplayTab/Resolution

@onready var restore: Button = $Restore

# Save system variables
const SAVE_PATH := "user://settings.cfg"
var settings_data: Dictionary = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"muted": false
	},
	"display": {
		"windowed": false,
		"borderless": true,
		"fullscreen": true,
		"resolution": "1280x720"
	}
}

func _ready():
	hide()
	# Load settings immediately when game starts
	_load_settings()
	_apply_settings_to_ui()
	
	restore.pressed.connect(reset_to_defaults)
	
	# Connect tab buttons
	display.pressed.connect(_on_display_pressed)
	audio.pressed.connect(_on_audio_pressed)
	
	# Connect audio controls
	h_slider.value_changed.connect(_on_master_volume_changed)
	h_slider_2.value_changed.connect(_on_music_volume_changed)
	h_slider_3.value_changed.connect(_on_sfx_volume_changed)
	check_box.toggled.connect(_on_mute_toggled)
	
	# Connect display controls
	check_box_windowed.toggled.connect(_on_windowed_toggled)
	check_box_borderless.toggled.connect(_on_borderless_toggled)
	check_box_fullscreen.toggled.connect(_on_fullscreen_toggled)
	close.pressed.connect(_show.bind(false))
	# Setup resolution menu button
	_setup_resolution_menu()

func _show(value):
	if value:
		_load_settings()
		show()
	else:
		hide()
		save_settings_manual()
	
func _setup_resolution_menu():
	var popup = resolution.get_popup()
	popup.clear()
	popup.add_item("1920x1080")
	popup.add_item("1366x768")
	popup.add_item("1280x720")
	popup.add_item("1024x768")
	popup.id_pressed.connect(_on_resolution_selected)

func _on_display_pressed():
	display_tab.show()
	audio_tab.hide()

func _on_audio_pressed():
	audio_tab.show()
	display_tab.hide()

# Audio control handlers
func _on_master_volume_changed(value: float):
	settings_data["audio"]["master_volume"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_changed(value: float):
	settings_data["audio"]["music_volume"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	settings_data["audio"]["sfx_volume"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_mute_toggled(toggled: bool):
	settings_data["audio"]["muted"] = toggled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), toggled)

# Display control handlers
func _on_windowed_toggled(toggled: bool):
	settings_data["display"]["windowed"] = toggled
	if toggled:
		get_window().mode = Window.MODE_WINDOWED
		check_box_fullscreen.set_pressed_no_signal(false)
		settings_data["display"]["fullscreen"] = false

func _on_borderless_toggled(toggled: bool):
	settings_data["display"]["borderless"] = toggled
	get_window().borderless = toggled

func _on_fullscreen_toggled(toggled: bool):
	settings_data["display"]["fullscreen"] = toggled
	if toggled:
		get_window().mode = Window.MODE_FULLSCREEN
		check_box_windowed.set_pressed_no_signal(false)
		settings_data["display"]["windowed"] = false

func _on_resolution_selected(id: int):
	var popup = resolution.get_popup()
	var resolution_text = popup.get_item_text(id)
	settings_data["display"]["resolution"] = resolution_text
	
	# Apply resolution
	var parts = resolution_text.split("x")
	if parts.size() == 2:
		var width = int(parts[0])
		var height = int(parts[1])
		get_window().size = Vector2i(width, height)

# Save settings when the settings menu is hidden
func _on_visibility_changed():
	if not visible:
		_save_settings()

# Built-in save system
func _save_settings():
	var config = ConfigFile.new()
	
	# Save audio settings
	config.set_value("audio", "master_volume", settings_data["audio"]["master_volume"])
	config.set_value("audio", "music_volume", settings_data["audio"]["music_volume"])
	config.set_value("audio", "sfx_volume", settings_data["audio"]["sfx_volume"])
	config.set_value("audio", "muted", settings_data["audio"]["muted"])
	
	# Save display settings
	config.set_value("display", "windowed", settings_data["display"]["windowed"])
	config.set_value("display", "borderless", settings_data["display"]["borderless"])
	config.set_value("display", "fullscreen", settings_data["display"]["fullscreen"])
	config.set_value("display", "resolution", settings_data["display"]["resolution"])
	
	# Save to file
	var error = config.save(SAVE_PATH)
	if error == OK:
		print("Settings saved successfully!")
	else:
		push_error("Failed to save settings: Error code " + str(error))

# Built-in load system
func _load_settings():
	var config = ConfigFile.new()
	
	var error = config.load(SAVE_PATH)
	if error != OK:
		print("No saved settings found, using defaults.")
		return
	
	# Load audio settings
	if config.has_section_key("audio", "master_volume"):
		settings_data["audio"]["master_volume"] = config.get_value("audio", "master_volume")
	if config.has_section_key("audio", "music_volume"):
		settings_data["audio"]["music_volume"] = config.get_value("audio", "music_volume")
	if config.has_section_key("audio", "sfx_volume"):
		settings_data["audio"]["sfx_volume"] = config.get_value("audio", "sfx_volume")
	if config.has_section_key("audio", "muted"):
		settings_data["audio"]["muted"] = config.get_value("audio", "muted")
	
	# Load display settings
	if config.has_section_key("display", "windowed"):
		settings_data["display"]["windowed"] = config.get_value("display", "windowed")
	if config.has_section_key("display", "borderless"):
		settings_data["display"]["borderless"] = config.get_value("display", "borderless")
	if config.has_section_key("display", "fullscreen"):
		settings_data["display"]["fullscreen"] = config.get_value("display", "fullscreen")
	if config.has_section_key("display", "resolution"):
		settings_data["display"]["resolution"] = config.get_value("display", "resolution")
	
	print("Settings loaded successfully!")

func _apply_settings_to_ui():
	# Apply audio settings to UI elements
	if h_slider:
		h_slider.set_value_no_signal(settings_data["audio"]["master_volume"])
	if h_slider_2:
		h_slider_2.set_value_no_signal(settings_data["audio"]["music_volume"])
	if h_slider_3:
		h_slider_3.set_value_no_signal(settings_data["audio"]["sfx_volume"])
	if check_box:
		check_box.set_pressed_no_signal(settings_data["audio"]["muted"])
	
	# Apply display settings to UI elements
	if check_box_windowed:
		check_box_windowed.set_pressed_no_signal(settings_data["display"]["windowed"])
	if check_box_borderless:
		check_box_borderless.set_pressed_no_signal(settings_data["display"]["borderless"])
	if check_box_fullscreen:
		check_box_fullscreen.set_pressed_no_signal(settings_data["display"]["fullscreen"])
	
	# Apply resolution to UI
	if resolution:
		var current_res = settings_data["display"]["resolution"]
		resolution.text = current_res
	
	# Apply actual audio settings to audio system
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 
		linear_to_db(settings_data["audio"]["master_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 
		linear_to_db(settings_data["audio"]["music_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 
		linear_to_db(settings_data["audio"]["sfx_volume"]))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), 
		settings_data["audio"]["muted"])
	
	# Apply display settings to window
	if settings_data["display"]["fullscreen"]:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	
	get_window().borderless = settings_data["display"]["borderless"]
	
	# Apply resolution to window
	var parts = settings_data["display"]["resolution"].split("x")
	if parts.size() == 2:
		var width = int(parts[0])
		var height = int(parts[1])
		get_window().size = Vector2i(width, height)

# Manual save function
func save_settings_manual():
	_save_settings()

# Reset to default settings
func reset_to_defaults():
	settings_data = {
		"audio": {
			"master_volume": 1.0,
			"music_volume": 1.0,
			"sfx_volume": 1.0,
			"muted": false
		},
		"display": {
			"windowed": false,
			"borderless": true,
			"fullscreen": true,
			"resolution": "1280x720"
		}
	}
	_apply_settings_to_ui()
	_save_settings()

# Get specific setting value
func get_setting(section: String, key: String):
	if settings_data.has(section) and settings_data[section].has(key):
		return settings_data[section][key]
	return null

# Force save current settings
func force_save():
	_save_settings()

# Call this function from your main game script to ensure settings are loaded at startup
func initialize_settings():
	_load_settings()
	_apply_settings_to_ui()
