extends Node2D

@export var speed = 250

var velocity = Vector2.ZERO

func _after_add():
	velocity.x = speed
	velocity = velocity.rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
