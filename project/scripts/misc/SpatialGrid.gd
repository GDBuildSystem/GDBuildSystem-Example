class_name SpatialGrid
extends RefCounted

var _grid: Dictionary[Vector2i, Variant] = {}

func _to_cell_key(position: Vector2) -> Vector2i:
    return Vector2i(floori(position.x), floori(position.y))

func insert(position: Vector2, value: Variant) -> void:
    var cell_key: Vector2i = _to_cell_key(position)
    if not _grid.has(cell_key):
        _grid[cell_key] = []
    _grid[cell_key].append(value)

func remove(position: Vector2) -> Variant:
    var cell_key: Vector2i = _to_cell_key(position)
    if _grid.has(cell_key):
        var cell: Variant = _grid[cell_key]
        _grid.erase(cell_key)
        return cell
    return null
func query(position: Vector2, radius: float) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var cell_key: Vector2i = _to_cell_key(position)
    var min_x: int = cell_key.x - int(radius)
    var max_x: int = cell_key.x + int(radius)
    var min_y: int = cell_key.y - int(radius)
    var max_y: int = cell_key.y + int(radius)
    for x in range(min_x, max_x + 1):
        for y in range(min_y, max_y + 1):
            var key: Vector2i = Vector2i(x, y)
            if _grid.has(key):
                result.append({key: _grid[key]})
    return result