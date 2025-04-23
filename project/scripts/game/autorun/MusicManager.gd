extends AudioStreamPlayer

var _current_player: AudioStreamPlayer
var _transition_player: AudioStreamPlayer
var _other_player: AudioStreamPlayer

func _ready() -> void:
    _other_player = AudioStreamPlayer.new()
    add_child(_other_player)
    _current_player = self
    _transition_player = _other_player

func _process(delta: float) -> void:
    if _transition_player.playing:
        _transition_player.volume_db = lerpf(_transition_player.volume_db, 0.0, delta)
        if _current_player.playing:
            _transition_player.volume_db = lerpf(_transition_player.volume_db, -80.0, delta)
            if _transition_player.volume_db == 0.0:
                _current_player.stop()
                _swap_players()
    
func queue_music(stream: AudioStream) -> void:
    if _current_player.stream == null:
        _current_player.stream = stream
        _current_player.play()
        return
    _transition_player.stream = stream
    _transition_player.volume_db = -80.0
    _transition_player.play()

func _swap_players() -> void:
    if _current_player == self:
        _current_player = _other_player
        _transition_player = self
    else:
        _current_player = self
        _transition_player = _other_player
