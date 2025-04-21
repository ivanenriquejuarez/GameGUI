extends Node

# Audio references
var current_music: AudioStreamPlayer
var splash_music = preload("res://Assets/sfx/1 titles INITIAL.wav")
var main_music = preload("res://Assets/sfx/4 town INITIAL.wav")
var current_track = ""

# Volume settings (0-100 scale for sliders)
var master_volume: float = 100.0
var sfx_volume: float = 50.0
var music_volume: float = 50.0

# Bus indices for easier reference
const MASTER_BUS_IDX = 0
const SFX_BUS_IDX = 1
const MUSIC_BUS_IDX = 2

# Base music dB level
const BASE_MUSIC_DB = 7.0

# Track-specific volume offsets to balance their loudness
var track_volume_offsets = {
	"splash": 0.0,  # Adjust this value if splash is too loud
	"main": 7     # Adjust this value if main is too quiet
}

func _ready():
	# Set up music player
	current_music = AudioStreamPlayer.new()
	add_child(current_music)
	current_music.bus = "music"
	
	# Load saved volume settings if available
	load_volume_settings()

# This function can be called from any scene to ensure audio is consistent
func ensure_audio_state():
	# Re-apply volume settings to all buses
	var master_idx = AudioServer.get_bus_index("Master")
	var sfx_idx = AudioServer.get_bus_index("sfx")
	var music_idx = AudioServer.get_bus_index("music")
	
	AudioServer.set_bus_volume_db(master_idx, percent_to_db(master_volume))
	AudioServer.set_bus_volume_db(sfx_idx, percent_to_db(sfx_volume))
	AudioServer.set_bus_volume_db(music_idx, percent_to_db(music_volume))
	
	# Ensure current music has correct volume with its track-specific offset
	if current_music and current_music.playing:
		_apply_track_volume()

func play_music(music_resource, track_name):
	# Only change the music if it's a different track
	if current_track != track_name:
		current_track = track_name
		
		# If music is already playing, create a crossfade
		if current_music.playing:
			# Create a new temporary audio player for the old track
			var old_player = AudioStreamPlayer.new()
			add_child(old_player)
			old_player.stream = current_music.stream
			old_player.volume_db = current_music.volume_db
			old_player.bus = "music"
			old_player.play(current_music.get_playback_position())
			
			# Start playing the new music immediately
			_set_new_music(music_resource)
			
			# Fade out old track
			var tween = create_tween()
			tween.tween_property(old_player, "volume_db", -80, 1.0)
			tween.tween_callback(func(): old_player.queue_free())
		else:
			# No music playing, just start the new track
			_set_new_music(music_resource)

# Helper function to set and play new music
func _set_new_music(music_resource):
	current_music.stream = music_resource
	_apply_track_volume()
	current_music.play()

# Apply the correct volume to the current track, including its offset
func _apply_track_volume():
	var base_volume = BASE_MUSIC_DB
	
	# Apply track-specific offset if available
	if track_volume_offsets.has(current_track):
		base_volume += track_volume_offsets[current_track]
	
	current_music.volume_db = base_volume

func play_splash_music():
	play_music(splash_music, "splash")

func play_main_music():
	play_music(main_music, "main")

# VOLUME CONTROL FUNCTIONS
# Convert slider value (0-100) to decibels
func percent_to_db(percent: float) -> float:
	if percent <= 0:
		return -80.0  # Silent
	
	# Better scaling for audible range
	return lerp(-20.0, 0.0, percent / 100.0)

# Set volume for a specific bus WITHOUT automatic saving
func set_bus_volume(bus_name: String, percent: float, save_settings: bool = false):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		var volume_db = percent_to_db(percent)
		AudioServer.set_bus_volume_db(bus_idx, volume_db)
		
		# Store the values
		match bus_name:
			"Master":
				master_volume = percent
			"sfx":
				sfx_volume = percent
			"music":
				music_volume = percent
				# If changing music volume, also update current track
				if current_music and current_music.playing:
					_apply_track_volume()
		
		# Only save if explicitly requested
		if save_settings:
			save_volume_settings()

# Convenience methods for each bus
func set_master_volume(percent: float, save_settings: bool = false):
	set_bus_volume("Master", percent, save_settings)

func set_sfx_volume(percent: float, save_settings: bool = false):
	set_bus_volume("sfx", percent, save_settings)

func set_music_volume(percent: float, save_settings: bool = false):
	set_bus_volume("music", percent, save_settings)

# Save settings to config file - call this explicitly when needed
func save_volume_settings():
	var config = ConfigFile.new()
	config.set_value("Audio", "master_volume", master_volume)
	config.set_value("Audio", "sfx_volume", sfx_volume)
	config.set_value("Audio", "music_volume", music_volume)
	config.save("user://audio_settings.cfg")

# Load settings from config file
func load_volume_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		# Get values from config file
		master_volume = config.get_value("Audio", "master_volume", 100.0)
		sfx_volume = config.get_value("Audio", "sfx_volume", 50.0)
		music_volume = config.get_value("Audio", "music_volume", 50.0)
		
		# Apply loaded values
		set_bus_volume("Master", master_volume)
		set_bus_volume("sfx", sfx_volume)
		set_bus_volume("music", music_volume)
	else:
		# Set default values if no config exists
		set_bus_volume("Master", 100.0)
		set_bus_volume("sfx", 50.0)
		set_bus_volume("music", 50.0)
