extends Control

@onready var new_project_button = $VBoxContainer/NewGame
@onready var load_project_button = $VBoxContainer/LoadGame
@onready var settings_button = $VBoxContainer/Settings
@onready var exit_button = $VBoxContainer/Exit

@onready var sfx_button = $SFX
@onready var music_button = $Music

var is_sfx_muted: bool = false
var is_music_muted: bool = false

# Textures for SFX button
var sfx_normal_texture = preload("res://Assets/sfxMute.png")
var sfx_hover_texture = preload("res://Assets/sfxHover.png")
var sfx_muted_texture = preload("res://Assets/sfxMuted.png")

# Textures for Music button
var music_normal_texture = preload("res://Assets/musicMute.png")
var music_hover_texture = preload("res://Assets/musicHover.png")
var music_muted_texture = preload("res://Assets/musicPressed.png")

func _ready():
	# Connect button signals
	new_project_button.pressed.connect(_on_new_project_pressed)
	load_project_button.pressed.connect(_on_load_project_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Hover sound
	new_project_button.mouse_entered.connect(_on_button_hovered)
	load_project_button.mouse_entered.connect(_on_button_hovered)
	settings_button.mouse_entered.connect(_on_button_hovered)
	exit_button.mouse_entered.connect(_on_button_hovered)

	# Press sound
	new_project_button.pressed.connect(_on_button_pressed)
	load_project_button.pressed.connect(_on_button_pressed)
	settings_button.pressed.connect(_on_button_pressed)
	exit_button.pressed.connect(_on_button_pressed)

	# SFX and Music button connections
	sfx_button.pressed.connect(_on_sfx_button_pressed)
	sfx_button.mouse_entered.connect(_on_sfx_hovered)
	music_button.pressed.connect(_on_music_button_pressed)
	music_button.mouse_entered.connect(_on_music_hovered)

	# Set initial textures
	sfx_button.texture_normal = sfx_normal_texture
	music_button.texture_normal = music_normal_texture

	# Play main music if not already playing
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_main_music()

func _on_new_project_pressed():
	get_tree().change_scene_to_file("res://Scenes/Designer/Designer.tscn")

func _on_load_project_pressed():
	get_tree().change_scene_to_file("res://Scenes/load_game.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_button_hovered():
	ButtonHoverSound.play_hover_sound()

func _on_button_pressed():
	ButtonHoverSound.play_press_sound()

# --- SFX BUTTON ---
func _on_sfx_button_pressed():
	is_sfx_muted = !is_sfx_muted

	if is_sfx_muted:
		AudioManager.set_sfx_volume(0)
		sfx_button.texture_normal = sfx_muted_texture
	else:
		AudioManager.set_sfx_volume(50)
		sfx_button.texture_normal = sfx_normal_texture

func _on_sfx_hovered():
	if !is_sfx_muted:
		sfx_button.texture_normal = sfx_hover_texture
		await get_tree().create_timer(0.1).timeout
	sfx_button.texture_normal = sfx_muted_texture if is_sfx_muted else sfx_normal_texture

# --- MUSIC BUTTON ---
func _on_music_button_pressed():
	is_music_muted = !is_music_muted

	if is_music_muted:
		AudioManager.set_music_volume(0)
		music_button.texture_normal = music_muted_texture
	else:
		AudioManager.set_music_volume(50)
		music_button.texture_normal = music_normal_texture

func _on_music_hovered():
	if !is_music_muted:
		music_button.texture_normal = music_hover_texture
		await get_tree().create_timer(0.1).timeout
	music_button.texture_normal = music_muted_texture if is_music_muted else music_normal_texture
