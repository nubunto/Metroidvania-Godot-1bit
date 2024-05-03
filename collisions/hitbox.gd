class_name Hitbox
extends Area2D

signal hit(hurtbox: Hurtbox)
signal hit_body(body)

@export var damage = 1

func _on_area_entered(hurtbox: Area2D):
	if not hurtbox is Hurtbox:
		return
	hurtbox.take_hit(self)
	self.hit.emit(hurtbox)

func _on_body_entered(body):
	self.hit_body.emit(body)
