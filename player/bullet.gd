extends Projectile

func _ready():
	set_process(false)

func _on_hitbox_hit(_hurtbox):
	super.explode()

func _on_hitbox_hit_body(body):
	super.explode_no_screenshake()
