extends Control

@onready var empty = $Empty
@onready var full = $Full

func _ready():
	PlayerStats.health_changed.connect(self.update_health_ui)
	PlayerStats.max_health_changed.connect(self.update_max_health_ui)

func update_health_ui(health: int):
	full.size.x = health * 5 + 1
	
func update_max_health_ui(max_health: int):
	empty.size.x = max_health * 5 + 1
