extends RigidBody2D

func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

func initialize(pos, dir):
	position = pos
	rotation = dir
	
	# Set the velocity
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	linear_velocity = velocity.rotated(dir)
	
	# Set the angular velocity to 0 to prevent spinning
	angular_velocity = 0
	# Lock rotation to prevent physics from rotating the mob
	lock_rotation = true

func _on_VisibilityNotifier2D_screen_exited():
	queue_free() 
