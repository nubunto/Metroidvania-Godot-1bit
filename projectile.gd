class_name Projectile
extends Node2D

const ExplosionEffectScene = preload("res://effects/explosion_effect.tscn")

@export var speed = 250

var velocity = Vector2.ZERO

func _after_add():
	velocity.x = speed
	velocity = velocity.rotated(rotation)

func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
	
func explode():
	Utils.instantiate_scene_on_world(ExplosionEffectScene, global_position)
	Events.add_screenshake.emit(0.4, 0.2)
	call_deferred("queue_free")

func explode_no_screenshake():
	Utils.instantiate_scene_on_world(ExplosionEffectScene, global_position)
	call_deferred("queue_free")

func _on_hitbox_hit(_hurtbox):
	self.explode_no_screenshake()

func _on_hitbox_hit_body(_body):
	self.explode_no_screenshake()
