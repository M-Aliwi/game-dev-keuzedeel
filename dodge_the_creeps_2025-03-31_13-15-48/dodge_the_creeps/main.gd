extends Node

var mob_scene
var bullet_scene
var boss_scene
var kills = 0
var time_survived = 0
var total_skill_points = 0
var current_upgrades = null
var boss_spawned = false

func _ready():
	randomize()
	mob_scene = preload("res://mob.tscn")
	bullet_scene = preload("res://bullet.tscn")
	boss_scene = preload("res://boss.tscn")
	print("Boss scene loaded: ", boss_scene != null)

func new_game():
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	kills = 0
	time_survived = 0
	boss_spawned = false
	$ScoreTimer.start()
	$MobTimer.start()
	$Player.start($StartPosition.position)
	$HUD.update_score(kills, time_survived)
	$HUD.show_message("Get Ready")
	await $StartTimer.timeout

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$DeathSound.play()
	
	# Calculate skill points earned based on both stats
	var kill_points = kills / 5  # 1 point per 5 kills
	var time_points = time_survived / 30  # 1 point per 30 seconds
	var points_earned = 1 + kill_points + time_points  # Base point + points from both stats
	total_skill_points += points_earned
	
	# Show skill tree after a delay
	await get_tree().create_timer(2.0).timeout
	$SkillTree.show_skill_tree(total_skill_points)

func _on_MobTimer_timeout():
	if boss_spawned:
		return
		
	print("Time survived: ", time_survived)
	# Check if boss should spawn (after 20 seconds)
	if time_survived >= 20:
		print("Attempting to spawn boss")
		spawn_boss()
		boss_spawned = true
		return
		
	# Spawn regular mob
	var mob = mob_scene.instantiate()
	add_child(mob)
	
	# Choose a random location on Path2D
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	# Set the mob's position and direction
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	
	mob.initialize(mob_spawn_location.position, direction)
	
	# Connect mob's tree_exited signal to update kills
	mob.tree_exited.connect(func(): kills += 1; $HUD.update_score(kills, time_survived))

func spawn_boss():
	print("Spawning boss...")
	var boss = boss_scene.instantiate()
	add_child(boss)
	# Initialize the boss at a random position along the top of the screen
	boss.initialize(Vector2(randf_range(50, 750), 50))
	$HUD.show_message("BOSS INCOMING!")
	print("Boss spawned at: ", boss.position)

func boss_defeated():
	$HUD.show_message("BOSS DEFEATED!")
	# Award bonus kills for defeating the boss
	kills += 10
	$HUD.update_score(kills, time_survived)

func _on_ScoreTimer_timeout():
	time_survived += 1
	$HUD.update_score(kills, time_survived)
	
	# Spawn boss after 20 seconds
	if time_survived == 20 and not boss_spawned:
		spawn_boss()
		boss_spawned = true

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_Player_shoot(direction):
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.position = $Player.position
	bullet.set_direction(direction)
	if current_upgrades:
		bullet.set_upgrades(current_upgrades)

func _on_SkillTree_upgrades_selected(upgrades):
	current_upgrades = upgrades
	$SkillTree.hide()
	new_game()
