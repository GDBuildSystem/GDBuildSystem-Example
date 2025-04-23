extends AudioStreamPlayer
class_name UI_SFX_Manager

enum AudioEvent {
    ON_ENTER,
    ON_EXIT,
    ON_CLICKED
}

@export var audio_events: Dictionary[AudioEvent, AudioStream] = {}
@export var root_control: Control

func _ready() -> void:
    if root_control == null:
        push_error("Root Control cannot be null, in UI SFX Manager...")
        return
    install(root_control)
    
func install(root: Control) -> void:
    if root is BaseButton:
        root.pressed.connect(_on_clicked)
    root.mouse_entered.connect(_on_entered)
    root.mouse_exited.connect(_on_exited)

func _on_clicked() -> void:
    if not audio_events.has(AudioEvent.ON_CLICKED):
        return
    stop()
    stream = audio_events[AudioEvent.ON_CLICKED]
    play()
func _on_entered() -> void:
    if not audio_events.has(AudioEvent.ON_ENTER):
        return
    stop()
    stream = audio_events[AudioEvent.ON_ENTER]
    play()
func _on_exited() -> void:
    if not audio_events.has(AudioEvent.ON_EXIT):
        return
    stop()
    stream = audio_events[AudioEvent.ON_EXIT]
    play()
