extends CanvasLayer

signal start_game

func update_score(kills: int, time: int):
	$ScoreLabel.text = "Kills: %s\nTime: %s" % [kills, time]

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$Message.text = "Dodge the\nCreeps!"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func _on_StartButton_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_MessageTimer_timeout():
	$Message.hide()
