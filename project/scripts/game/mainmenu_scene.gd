extends Node

@export var update_music: AudioStream
@export var play_scene: PackedScene
@export var settings_panel: Panel
@export var credits_panel: Panel

func _ready() -> void:
    MusicManager.queue_music(update_music)

func _on_play_button_pressed() -> void:
    if play_scene == null:
        push_error("No Play Scene available!")
        return
    get_tree().change_scene_to_packed(play_scene)

func _on_settings_button_pressed() -> void:
    settings_panel.visible = true

func _on_credits_button_pressed() -> void:
    credits_panel.visible = true

func _on_exit_button_pressed() -> void:
    get_tree().quit(0)
