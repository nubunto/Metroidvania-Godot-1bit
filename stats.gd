class_name Stats extends Node

@export var max_health: int = 3: set = set_max_health
@onready var health: int = max_health : set = set_health

signal no_health
signal health_changed(new_value: int)
signal max_health_changed(new_value: int)

func connect_to_hurtbox(hurtbox: Hurtbox):
	hurtbox.hurt.connect(self.take_damage)

func set_max_health(value: int):
	max_health = value
	max_health_changed.emit(max_health)

func set_health(value: int):
	health = clamp(value, 0, max_health)
	health_changed.emit(health)
	if health <= 0:
		no_health.emit()

func take_damage(hitbox: Hitbox):
	self.health -= hitbox.damage
