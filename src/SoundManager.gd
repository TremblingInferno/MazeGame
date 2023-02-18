extends Node


func play_death_sound():
	$DeathSound.play()


func play_music():
	$BackgroundMusic.stop()
	$BackgroundMusic.play()


func play_level_creation():
	$CreatingLevel.play()

