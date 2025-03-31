extends Area2D

var speed = 750
var direction = Vector2.UP
var upgrades = null

func _ready():
	# Connect the area_entered signal to handle collisions
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Rotate bullet sprite to match direction
	rotation = direction.angle()
	
	# Apply bullet size upgrade if available
	if upgrades and "bullet_size" in upgrades:
		var scale_factor = 1.0 + upgrades["bullet_size"]["level"] * 0.1
		scale = Vector2(scale_factor, scale_factor)

func set_direction(new_direction):
	direction = new_direction
	rotation = direction.angle()

func set_upgrades(new_upgrades):
	upgrades = new_upgrades
	if upgrades and "bullet_size" in upgrades:
		var scale_factor = 1.0 + upgrades["bullet_size"]["level"] * 0.1
		scale = Vector2(scale_factor, scale_factor)

func _process(delta):
	# Apply bullet speed upgrade if available
	var current_speed = speed
	if upgrades and "bullet_speed" in upgrades:
		current_speed *= (1.0 + upgrades["bullet_speed"]["level"] * 0.1)
	
	# Move the bullet in the specified direction
	position += direction * current_speed * delta
	
	# Delete the bullet if it goes off screen
	var screen_size = get_viewport_rect().size
	if position.x < -50 or position.x > screen_size.x + 50 or \
	   position.y < -50 or position.y > screen_size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("mobs"):
		area.queue_free()  # Regular mobs die instantly
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.queue_free()  # Regular mobs die instantly
		queue_free()
	elif body.is_in_group("boss"):
		body.take_damage()  # Boss handles its own health
		queue_free() 