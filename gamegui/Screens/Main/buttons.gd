extends Button
@onready var full: TileMapLayer = $full
@onready var hover: TileMapLayer = $hover
@onready var corner_hover: TileMapLayer = $corner_hover
@onready var audio_hover: AudioStreamPlayer2D = $"../../../../../audio_hover"
@onready var audio_select: AudioStreamPlayer2D = $"../../../../../audio_select"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover.visible = false  # Show hover layer
	corner_hover.visible = false  # Show hover layer
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

			
func _on_mouse_entered() -> void:
	hover.visible = true
	corner_hover.visible = true
	full.visible = false
	audio_hover.play()
	
func _on_mouse_exited() -> void:
	full.visible = true
	hover.visible = false
	corner_hover.visible = false
