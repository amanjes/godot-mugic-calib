extends Node3D

@onready var heading_label = $Heading
@onready var subtext_label = $Subtext
var voices = DisplayServer.tts_get_voices_for_language("en")
var voice_id = voices[0]
var tts = DisplayServer.tts_is_speaking()

# Called when the node enters the scene tree for the first time.
func _ready():
	heading_label.text = "Calibration"
	subtext_label.text = "Please connect your Mugic Devices"
	
	DisplayServer.tts_speak(subtext_label.text, "en")
	
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			#SWITCH TO MAIN SCENE
			get_tree().change_scene_to_file("res://mugic-calibration.tscn")
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
