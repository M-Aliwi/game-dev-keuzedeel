extends RigidBody2D

var health = 10
var speed = 100  # Slower speed for the boss
var player = null

func _enter_tree():
	# Connect to bullet collision
	$BulletDetector.area_entered.connect(_on_area_entered)

func _ready():
	# Set up initial health bar value
	$HealthBar.max_value = health
	$HealthBar.value = health
	
	# Find the player node
	player = get_node("/root/Main/Player")
	
	# Start the flying animation
	$AnimatedSprite2D.play("fly")

func _physics_process(delta):
	if player:
		# Calculate direction to player
		var direction = (player.position - position).normalized()
		# Move towards player
		linear_velocity = direction * speed

func initialize(pos):
	position = pos
	
	# Prevent rotation
	angular_velocity = 0
	lock_rotation = true

func _on_area_entered(area):
	if area.is_in_group("bullets"):
		take_damage()
		area.queue_free()

func take_damage():
	health -= 1
	$HealthBar.value = health
	if health <= 0:
		# Signal main to award points and update game state
		get_parent().boss_defeated()
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	# For boss, don't destroy when leaving screen, just stop at screen edges
	var view_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, view_size.x)
	position.y = clamp(position.y, 0, view_size.y) 
