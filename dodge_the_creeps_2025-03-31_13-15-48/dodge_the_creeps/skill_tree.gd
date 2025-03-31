extends CanvasLayer

signal upgrades_selected

var skill_points = 0
var upgrades = {
	"speed": {"level": 0, "cost": 1, "max_level": 5},
	"bullet_speed": {"level": 0, "cost": 1, "max_level": 5},
	"fire_rate": {"level": 0, "cost": 1, "max_level": 5},
	"bullet_size": {"level": 0, "cost": 1, "max_level": 5}
}

func _ready():
	hide()
	update_buttons()

func show_skill_tree(points):
	skill_points = points
	update_buttons()
	show()

func update_buttons():
	$Panel/Points.text = "Skill Points: " + str(skill_points)
	
	var speed_upgrade = upgrades["speed"]
	$Panel/GridContainer/SpeedUpgrade.text = "Movement Speed\nLevel: " + str(speed_upgrade["level"]) + "\nCost: 1"
	$Panel/GridContainer/SpeedUpgrade.disabled = skill_points < speed_upgrade["cost"] or speed_upgrade["level"] >= speed_upgrade["max_level"]
	
	var bullet_speed_upgrade = upgrades["bullet_speed"]
	$Panel/GridContainer/BulletSpeedUpgrade.text = "Bullet Speed\nLevel: " + str(bullet_speed_upgrade["level"]) + "\nCost: 1"
	$Panel/GridContainer/BulletSpeedUpgrade.disabled = skill_points < bullet_speed_upgrade["cost"] or bullet_speed_upgrade["level"] >= bullet_speed_upgrade["max_level"]
	
	var fire_rate_upgrade = upgrades["fire_rate"]
	$Panel/GridContainer/FireRateUpgrade.text = "Fire Rate\nLevel: " + str(fire_rate_upgrade["level"]) + "\nCost: 1"
	$Panel/GridContainer/FireRateUpgrade.disabled = skill_points < fire_rate_upgrade["cost"] or fire_rate_upgrade["level"] >= fire_rate_upgrade["max_level"]
	
	var bullet_size_upgrade = upgrades["bullet_size"]
	$Panel/GridContainer/BulletSizeUpgrade.text = "Bullet Size\nLevel: " + str(bullet_size_upgrade["level"]) + "\nCost: 1"
	$Panel/GridContainer/BulletSizeUpgrade.disabled = skill_points < bullet_size_upgrade["cost"] or bullet_size_upgrade["level"] >= bullet_size_upgrade["max_level"]

func _on_SpeedUpgrade_pressed():
	if skill_points >= upgrades["speed"]["cost"] and upgrades["speed"]["level"] < upgrades["speed"]["max_level"]:
		skill_points -= upgrades["speed"]["cost"]
		upgrades["speed"]["level"] += 1
		update_buttons()

func _on_BulletSpeedUpgrade_pressed():
	if skill_points >= upgrades["bullet_speed"]["cost"] and upgrades["bullet_speed"]["level"] < upgrades["bullet_speed"]["max_level"]:
		skill_points -= upgrades["bullet_speed"]["cost"]
		upgrades["bullet_speed"]["level"] += 1
		update_buttons()

func _on_FireRateUpgrade_pressed():
	if skill_points >= upgrades["fire_rate"]["cost"] and upgrades["fire_rate"]["level"] < upgrades["fire_rate"]["max_level"]:
		skill_points -= upgrades["fire_rate"]["cost"]
		upgrades["fire_rate"]["level"] += 1
		update_buttons()

func _on_BulletSizeUpgrade_pressed():
	if skill_points >= upgrades["bullet_size"]["cost"] and upgrades["bullet_size"]["level"] < upgrades["bullet_size"]["max_level"]:
		skill_points -= upgrades["bullet_size"]["cost"]
		upgrades["bullet_size"]["level"] += 1
		update_buttons()

func _on_ContinueButton_pressed():
	hide()
	upgrades_selected.emit(upgrades)

func get_upgrade_multiplier(upgrade_name):
	var level = upgrades[upgrade_name]["level"]
	return 1.0 + (level * 0.2) # 20% increase per level 