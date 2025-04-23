extends Camera2D

@export var area: Area2D
@export var movement_speed: float = 500.0
@export var zoom_sensitivity: float = 0.2
@export var zoom_min: float = 0.5
@export var zoom_max: float = 2.0

var _shape: RectangleShape2D
var _collision_shape: CollisionShape2D
var _last_in_bounds: Vector2

func _ready() -> void:
    _collision_shape = area.get_node("CollisionShape2D")
    if _collision_shape and _collision_shape.shape is RectangleShape2D:
        _shape = _collision_shape.shape
    if _shape:
        # Center the last known bounds...
        _last_in_bounds = _collision_shape.global_position

func _input(event: InputEvent) -> void:
    _handle_input(event)
func _unhandled_input(event: InputEvent) -> void:
    _handle_input(event)
func _handle_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var zoomValue: float = zoom.x
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoomValue += event.factor * zoom_sensitivity
        if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoomValue -= event.factor * zoom_sensitivity
        zoomValue = clampf(zoomValue, zoom_min, zoom_max)
        zoom = Vector2(zoomValue, zoomValue)

func _process(delta: float) -> void:
    var move_direction: Vector2 = Vector2(Input.get_axis("camera_move_left", "camera_move_right"), Input.get_axis("camera_move_up", "camera_move_down"))
    
    global_position += move_direction * movement_speed * delta
    
    var bounds_pos: Vector2 = _collision_shape.global_position
    var extents: Vector2 = _shape.size
    
    var bounds_rect: Rect2 = Rect2(bounds_pos - extents / 2, extents)
    
    if bounds_rect.has_point(global_position):
        _last_in_bounds = global_position
    else:
        global_position = global_position.lerp(_last_in_bounds, delta * 2)
