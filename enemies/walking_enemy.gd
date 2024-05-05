extends CharacterBody2D

const EnemyDeathEffect = preload("res://effects/enemy_death_effect.tscn")

@export var speed = 30.0
@export var turns_at_ledges = true
@onready var floor_cast = $FloorCast
@onready var stats = $Stats
@onready var death_effect_location = $DeathEffectLocation

var gravity = 200
var direction = 1.0

@onready var sprite = $Sprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_wall():
		turn_around()
	if is_at_ledge() and turns_at_ledges:
		turn_around()

	velocity.x = direction * speed
	sprite.scale.x = direction

	move_and_slide()
	 
func is_at_ledge():
	return is_on_floor() and not floor_cast.is_colliding()

func turn_around():
	direction *= -1

func _on_hurtbox_hurt(hitbox: Hitbox):
	stats.health -= hitbox.damage

func _on_stats_no_health():
	Utils.instantiate_scene_on_world(EnemyDeathEffect, death_effect_location.global_position)
	queue_free()
