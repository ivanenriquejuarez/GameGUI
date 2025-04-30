extends Node2D

const BOSS_THEME = "res://Assets/Audio/Infinity Crystal_ Awakening wavs/14 BOSS fixing LOOP.wav"
@onready var return_button = $CanvasLayer/returnButton

func _ready():
	# Connect the button
	return_button.connect("pressed", Callable(self, "_on_return_button_pressed"))
	
	# Rest of your _ready function...
	var boss_music = load(BOSS_THEME)
	if boss_music:
		AudioManager.play_music(boss_music, "boss")
	# Instantiate designer objects
	for obj in DesignerState.pending_objects:
		var packed = load(obj["runtime_path"]) as PackedScene
		var pos = obj["position"]
		var instance = packed.instantiate()
		instance.global_position = pos
		# Apply saved scale if available
		instance.scale = obj["scale"] if "scale" in obj else Vector2(1, 1)
		add_child(instance)

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Designer/Designer.tscn")

func _exit_tree() -> void:
	# Restore previous music if desired (optional)
	if AudioManager.has_meta("previous_track"):
		var prev = AudioManager.get_meta("previous_track")
		match prev:
			"designer":
				AudioManager.play_music(load("res://Assets/Audio/Infinity Crystal_ Awakening wavs/6 sunny INITIAL.wav"), "designer")
			_:
				AudioManager.play_main_music()
