extends ColorRect

@export var min_flash_interval = 1.0  # Minimum time between flashes
@export var max_flash_interval = 5.0  # Maximum time between flashes
@export var flash_duration = 0.1      # How long each flash lasts
@export var flash_count = 2           # Number of flashes in a sequence
@export var flash_delay = 0.1         # Delay between flashes in a sequence

var material_override
var timer = 0.0
var next_flash_time = 0.0
var flashing = false
var flash_index = 0

func _ready():
	material_override = material as ShaderMaterial
	# Set first flash time
	next_flash_time = randf_range(min_flash_interval, max_flash_interval)

func _process(delta):
	timer += delta
	
	# Check if it's time for a new flash sequence
	if timer >= next_flash_time and not flashing:
		start_flash_sequence()
	
	# Update flash intensity during active flashing
	if flashing:
		update_flashing(delta)

func start_flash_sequence():
	flashing = true
	flash_index = 0
	# Start the first flash
	material_override.set_shader_parameter("flash_intensity", 1.0)
	
func update_flashing(delta):
	# Count down until flash should end
	if flash_index < flash_count * 2:  # Each flash has on and off state
		if timer >= next_flash_time + (flash_index * flash_delay):
			# Toggle flash on/off
			var is_on = flash_index % 2 == 0
			material_override.set_shader_parameter("flash_intensity", 1.0 if is_on else 0.0)
			flash_index += 1
	else:
		# End of sequence
		flashing = false
		material_override.set_shader_parameter("flash_intensity", 0.0)
		# Set time for next flash sequence
		next_flash_time = timer + randf_range(min_flash_interval, max_flash_interval)
