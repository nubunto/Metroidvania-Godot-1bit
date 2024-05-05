extends Node2D

const EnemyDeathEffect = preload("res://effects/enemy_death_effect.tscn")

enum DIRECTION {
	Left = -1,
	Right = 1
}

@export var crawling_direction: DIRECTION = DIRECTION.Right
@export var max_speed = 200

@onready var floor_cast = $FloorCast
@onready var wall_cast = $WallCast
@onready var stats: Stats = $Stats
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready():
	stats.connect_to_hurtbox(hurtbox)
	wall_cast.target_position.x *= crawling_direction

func _physics_process(delta):
	if wall_cast.is_colliding():
		global_position = wall_cast.get_collision_point()
		var wall_normal = wall_cast.get_collision_normal()
		rotation = wall_normal.rotated(deg_to_rad(90)).angle()
	else:
		floor_cast.rotation_degrees = -max_speed * crawling_direction * delta
		if floor_cast.is_colliding():
			global_position = floor_cast.get_collision_point()
			var floor_normal = floor_cast.get_collision_normal()
			rotation = floor_normal.rotated(deg_to_rad(90)).angle()
		else:
			rotation_degrees += crawling_direction * 2

func _on_stats_no_health():
	Utils.instantiate_scene_on_world(EnemyDeathEffect, floor_cast.global_position)
	queue_free()

func _on_hurtbox_hurt(hitbox: Hitbox):
	stats.take_damage(hitbox)
