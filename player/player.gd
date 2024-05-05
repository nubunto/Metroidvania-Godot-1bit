extends CharacterBody2D

@export var acceleration = 512
@export var max_fall_velocity = 80
@export var max_velocity = 64
@export var friction = 1024
@export var air_friction = 64
@export var gravity = 200
@export var jump_force = 128
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128
@export var dash_max_speed = 350


var air_jump = false
var can_dash = true
var dash_direction = 1
var state: Callable = move_state

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite
@onready var coyote_jump_timer = $CoyoteTimer
@onready var player_blaster = $PlayerBlaster
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var player_camera = $PlayerCamera
@onready var hurtbox = $Hurtbox
@onready var blinking_animation_player = $BlinkingAnimationPlayer
@onready var dash_cooldown_timer = $DashCooldownTimer
@onready var dash_momentum_timer = $DashMomentumTimer

const DustEffectScene = preload("res://effects/dust_effect_copied.tscn")
const JumpEffectScene = preload("res://effects/jump_effect.tscn")
const WallJumpEffectScene = preload("res://effects/wall_jump_effect.tscn")

func _ready():
	PlayerStats.no_health.connect(self.die)

func die():
	player_camera.reparent(get_tree().current_scene)
	queue_free()

func create_dust_effect():
	Utils.instantiate_scene_on_world(DustEffectScene, global_position)

func create_wall_jump_effect(effect_position):
	return Utils.instantiate_scene_on_world(WallJumpEffectScene, effect_position)

func dash_state(delta):
	var dash_max_speed = 250
	velocity.x = dash_max_speed * dash_direction
	velocity.y = 0
	move_and_slide()
	state = end_of_dash_state

func air_dash_state(delta):
	velocity.x = (dash_max_speed * 0.75) * dash_direction
	velocity.y = 0
	move_and_slide()
	state = end_of_air_dash_state

func end_of_air_dash_state(delta):
	if velocity.x == sign(velocity.x) * 100:
		buffer_momentum()
		state = move_state
		return
	if is_on_floor():
		buffer_momentum()
		state = move_state
		return
	velocity.x = move_toward(velocity.x, sign(velocity.x) * 100, 700 * delta)
	move_and_slide()

func end_of_dash_state(delta):
	if velocity.x == sign(velocity.x) * 100:
		buffer_momentum()
		state = move_state
		return
	if is_on_floor():
		buffer_momentum()
		state = move_state
		return
	velocity.x = move_toward(velocity.x, sign(velocity.x) * 100, 700 * delta)
	move_and_slide()

func buffer_momentum():
	dash_momentum_timer.start()

func dash_check():
	if Input.is_action_just_pressed("dash") and can_dash:
		dash_direction = Input.get_axis("move_left", "move_right")
		if dash_direction == 0:
			state = move_state
			return
		can_dash = false
		dash_cooldown_timer.start()
		animation_player.play("dash")
		if is_on_floor():
			state = dash_state
		else:
			state = air_dash_state

func wall_slide_state(delta):
	var wall_normal = get_wall_normal()
	animation_player.play("wall_slide")
	sprite.scale.x = sign(wall_normal.x)
	velocity.y = clampf(velocity.y, -wall_slide_speed, max_wall_slide_speed)
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta, wall_normal.x)

func wall_detach(delta, wall_x_axis):
	if Input.is_action_just_pressed("move_right") and wall_x_axis == 1:
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed("move_left") and wall_x_axis == -1:
		velocity.x = -acceleration * delta
		state = move_state
	
	if not is_on_wall() or is_on_floor():
		state = move_state

func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * 0.75)
		var wall_jump_effect_position = global_position + Vector2(wall_axis * 3, -2)
		var effect = create_wall_jump_effect(wall_jump_effect_position)
		effect.scale.x = wall_axis

func wall_check():
	if not is_on_floor() and is_on_wall():
		state = wall_slide_state
		air_jump = true

func apply_wall_slide_gravity(delta):
	var speed = wall_slide_speed
	if Input.is_action_pressed("crouch"):
		speed = max_wall_slide_speed
	velocity.y = move_toward(velocity.y, speed, gravity * delta)

func move_state(delta):
	apply_gravity(delta)

	var input_axis = Input.get_axis("move_left", "move_right")
	apply_horizontal_force(delta, input_axis)
	apply_friction(delta, input_axis)
	jump_check()
	
	if Input.is_action_just_pressed("crouch"):
		set_collision_mask_value(2, false)
		drop_timer.start()
		
	update_animations(input_axis)

	var was_on_floor = is_on_floor()
	move_and_slide()
	
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	
	wall_check()
	dash_check()

func _physics_process(delta):
	state.call(delta)

	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0:
		fire_rate_timer.start()
		player_blaster.fire_bullet()

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func apply_horizontal_force(delta, input_axis):
	if dash_momentum_timer.time_left > 0:
		return
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_left"):
		if is_on_floor():
			return
		velocity.x = move_toward(velocity.x, sign(velocity.x) * max_velocity, acceleration * delta)
		return

	if not is_moving(input_axis):
		return
	velocity.x = move_toward(velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta, input_axis):
	if is_moving(input_axis):
		return
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)
	

func jump_check():
	if is_on_floor():
		air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		air_jump = true
		if Input.is_action_just_pressed("jump"):
			jump(jump_force)
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < -jump_force / 2:
			jump(jump_force / 2, false)
		if Input.is_action_just_pressed("jump") and air_jump:
			jump(jump_force * 0.75, true)
			air_jump = false

func jump(force, should_effect = true):
	velocity.y = -force
	if should_effect: Utils.instantiate_scene_on_world(JumpEffectScene, global_position)

func update_animations(input_axis):
	sprite.scale.x = sign(get_local_mouse_position().x)
	if abs(sprite.scale.x) != 1:
		sprite.scale.x = 1
	if is_moving(input_axis):
		animation_player.play("run")
		animation_player.speed_scale = input_axis * sprite.scale.x
	else:
		animation_player.play("idle")
	
	if not is_on_floor():
		animation_player.play("jump")

func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)

func _on_hurtbox_hurt(_hitbox):
	Events.add_screenshake.emit(3, 0.25)
	PlayerStats.health -= 1
	blinking_animation_player.play("blink")

func _on_dash_timer_timeout():
	can_dash = true
	
