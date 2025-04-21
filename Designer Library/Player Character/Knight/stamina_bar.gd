extends ProgressBar

@onready var used_bar: ProgressBar = $Used_bar
@onready var timer: Timer = $Used_bar/Timer
@onready var stamina_node: Stamina = $"../../../Stamina"


var stamina: Stamina

func _ready() -> void:
	if stamina_node:
		stamina_node.connect("stamina_used", Callable(self, "_on_stamina_used"))
		stamina_node.connect("stamina_depleted", Callable(self, "_on_stamina_depleted"))
		init_stamina(stamina_node.max_stamina)
	else:
		print("Error: Stamina node could not be found.")

func init_stamina(max_stamina_value: float):
	max_value = max_stamina_value
	value = stamina_node.get_current_stamina()
	used_bar.max_value = max_stamina_value
	used_bar.value = stamina_node.get_current_stamina()

func _on_stamina_used(amount: float) -> void:
	value = stamina_node.get_current_stamina()
	timer.start()
	#print("Used_bar Value:", used_bar.value)
	#print("Used_bar Max Value:", used_bar.max_value)

func _on_stamina_depleted() -> void:
	value = 0

func _process(delta: float) -> void:
	# Continuously update the ProgressBar
	value = stamina_node.get_current_stamina()
	#used_bar.value = stamina_node.get_current_stamina()


func _on_timer_timeout() -> void:
	used_bar.value = stamina_node.get_current_stamina()
