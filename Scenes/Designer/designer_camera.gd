extends Camera2D

@export var pan_speed: float = 400.0  # Speed of panning movement
@export var zoom_speed: float = 0.1  # Speed of zooming
@export var min_zoom: float = 0.5  # Minimum zoom level
@export var max_zoom: float = 3.0  # Maximum zoom level

func _process(delta):
	_handle_panning(delta)
	_handle_zoom()

func _handle_panning(delta):
	var move_vector := Vector2.ZERO
	
	if Input.is_action_pressed("left"):  # A key
		move_vector.x -= 1
	if Input.is_action_pressed("right"):  # D key
		move_vector.x += 1
	if Input.is_action_pressed("up"):  # W key
		move_vector.y -= 1
	if Input.is_action_pressed("down"):  # S key
		move_vector.y += 1
	
	if move_vector != Vector2.ZERO:
		position += move_vector.normalized() * pan_speed * delta
		
		# Clamp the position so it doesn't go past (0,0)
		position.x = max(position.x, 0)
		position.y = max(position.y, 0)

func _handle_zoom():
	if Input.is_action_pressed("shift"):
		return
		
	if Input.is_action_just_pressed("zoom_out"):
		var new_zoom = zoom - Vector2(zoom_speed, zoom_speed)
		zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

	elif Input.is_action_just_pressed("zoom_in"):
		var new_zoom = zoom + Vector2(zoom_speed, zoom_speed)
		zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
