extends Camera2D

@onready var timer = $Timer

var shake = 0

func _process(_delta):
	offset.x = randf_range(-shake, shake)
	offset.y = randf_range(-shake, shake)

func _ready():
	Events.add_screenshake.connect(start_screenshake)
	timer.timeout.connect(_on_timer_timeout)
	
func start_screenshake(amount, duration):
	shake = amount
	timer.start(duration)

func _on_timer_timeout():
	shake = 0
