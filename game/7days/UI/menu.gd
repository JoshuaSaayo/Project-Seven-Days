extends Control

@onready var new_game: Button = $NewGame
@onready var load_game: Button = $LoadGame
@onready var setting: Button = $Setting
@onready var quit: Button = $Quit

@onready var prompt: Control = $Prompt
@onready var setting_tab: Control = $SettingTab

func _ready():
	new_game.pressed.connect(_on_new_game_pressed)
	load_game.pressed.connect(_on_load_game_pressed)
	setting.pressed.connect(_on_setting_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	# Connect prompt signals
	prompt.prompt_response.connect(_on_prompt_response)

func _on_new_game_pressed():
	prompt.setup("new_game", "Start a new game? Any unsaved progress will be lost.", "Yes", "No")

func _on_load_game_pressed():
	# Check if save file exists first
	if Save.save_exists(""):
		prompt.setup("load_game", "Load saved game?", "Yes", "No")
	else:
		prompt.setup("no_save", "No save file found.", "", "", "OK")

func _on_setting_pressed():
	setting_tab._show(true)

func _on_quit_pressed():
	prompt.setup("quit", "Are you sure you want to quit?", "Yes", "No")

func _on_prompt_response(code: String, result: bool):
	if result:  # User clicked Yes/OK
		match code:
			"new_game":
				print("Starting new game...")
				# Add your new game logic here
				Globals._change_scene(Constant.scene_main_map,5)
				
			"load_game":
				print("Loading game...")
				# Add your load game logic here
				Save.load_game("") # TODO NOT YET IMPLEMNETED
				Globals._change_scene(Constant.scene_main_map,5)
				
			"quit":
				get_tree().quit()
				
			"no_save":
				# Just close the prompt, no action needed
				pass
	else:  # User clicked No
		# Just close the prompt, no action needed
		print("User cancelled: ", code)
