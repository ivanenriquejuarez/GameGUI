extends Control

func play_hover_sound():
	if AudioManager.sfx_volume > 0:
		$AudioStreamPlayer.play()

func play_press_sound():
	if AudioManager.sfx_volume > 0:
		$AudioStreamPlayer2.play()
