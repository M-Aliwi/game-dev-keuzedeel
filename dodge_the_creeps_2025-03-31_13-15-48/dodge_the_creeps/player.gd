extends Area2D

signal hit
signal shoot(direction)

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var last_direction = Vector2.UP # Store the last movement direction
var fire_rate_cooldown = 0.5 # Time between shots
var can_shoot = true
var upgrades = null

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func get_aim_direction():
	# Get direction from player to mouse cursor
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - position).normalized()

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		var current_speed = speed
		if upgrades and "speed" in upgrades:
			current_speed *= (1.0 + upgrades["speed"]["level"] * 0.05)
		velocity = velocity.normalized() * current_speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position.x = clamp(position.x, 30, screen_size.x - 30)
	position.y = clamp(position.y, 30, screen_size.y - 30)

	# Update player animation based on aim direction
	var aim_direction = get_aim_direction()
	if abs(aim_direction.x) > abs(aim_direction.y):
		$AnimatedSprite2D.animation = &"right"
		$AnimatedSprite2D.flip_v = false
		$Trail.rotation = 0
		$AnimatedSprite2D.flip_h = aim_direction.x < 0
	else:
		$AnimatedSprite2D.animation = &"up"
		$AnimatedSprite2D.flip_v = aim_direction.y > 0

	if Input.is_action_just_pressed(&"shoot") and can_shoot:
		fire_bullet()
		can_shoot = false
		var cooldown = fire_rate_cooldown
		if upgrades and "fire_rate" in upgrades:
			cooldown /= (1.0 + upgrades["fire_rate"]["level"] * 0.2)
		await get_tree().create_timer(cooldown).timeout
		can_shoot = true

func start(pos):
	position = pos
	last_direction = Vector2.UP
	rotation = 0
	show()
	$CollisionShape2D.disabled = false

func fire_bullet():
	shoot.emit(get_aim_direction())

func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred(&"disabled", true)

func apply_upgrades(new_upgrades):
	upgrades = new_upgrades
