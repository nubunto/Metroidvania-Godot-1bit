extends CharacterBody2D

@export var acceleration = 512
@export var max_fall_velocity = 80
@export var max_velocity = 64
@export var friction = 256
@export var gravity = 200
@export var jump_force = 128
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite

const DustEffectScene = preload("res://effects/dust_effect.tscn")

func create_dust_effect():
	var dust_effect = DustEffectScene.instantiate()
	var main = get_tree().current_scene
	main.add_child(dust_effect)
	dust_effect.global_position = global_position

func _physics_process(delta):
	apply_gravity(delta)

	var input_axis = Input.get_axis("ui_left", "ui_right")
	apply_horizontal_force(delta, input_axis)
	apply_friction(delta, input_axis)
	jump_check()
	update_animations(input_axis)

	move_and_slide()

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func apply_horizontal_force(delta, input_axis):
	if not is_moving(input_axis):
		return
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta, input_axis):
	if is_moving(input_axis):
		return
	
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump_check():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -jump_force
	else:
		if Input.is_action_just_released("ui_up") and velocity.y < -jump_force/2:
			velocity.y = -jump_force / 2

func update_animations(input_axis):
	if is_moving(input_axis):
		animation_player.play("run")
		sprite.flip_h = sign(input_axis) == -1
	else:
		animation_player.play("idle")
	
	if not is_on_floor():
		animation_player.play("jump")
