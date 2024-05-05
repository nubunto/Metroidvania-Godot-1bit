extends Node2D

const EnemyDeathEffect = preload("res://effects/enemy_death_effect.tscn")
const EnemyBulletScene = preload("res://enemies/enemy_bullet.tscn")

@export var bullet_speed = 30
@export var spread_range = 45

@onready var stats = $Stats
@onready var bullet_spawn_point = $BulletSpawnPoint
@onready var fire_direction = $FireDirection


func fire_bullet():
	var bullet = Utils.instantiate_scene_on_world(EnemyBulletScene, bullet_spawn_point.global_position) as Projectile
	var direction = global_position.direction_to(fire_direction.global_position)
	var velocity = direction.normalized() * bullet_speed
	velocity = velocity.rotated(randf_range(-deg_to_rad(spread_range/2), deg_to_rad(spread_range/2)))
	bullet.velocity = velocity
	

func _on_stats_no_health():
	Utils.instantiate_scene_on_world(EnemyDeathEffect, bullet_spawn_point.global_position)
	queue_free()

func _on_hurtbox_hurt(hitbox: Hitbox):
	stats.health -= hitbox.damage
