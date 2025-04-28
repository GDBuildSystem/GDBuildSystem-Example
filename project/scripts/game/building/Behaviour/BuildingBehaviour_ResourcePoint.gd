class_name BuildingBehaviour_ResourcePoint
extends BuildingBehaviour

@export var resourceItem: ResourceItem
@export var max_gathers: int = 2
@export var quantity: int = 1
@export var gather_required_time: float = 5.0

var current_gatherers: Dictionary[Unit, float] = {}

func tick(delta: float) -> void:
    var extracted_gatherers: Array[Unit] = []
    for gatherer: Unit in current_gatherers:
        current_gatherers[gatherer] -= delta
        var time_left: float = current_gatherers[gatherer]
        if time_left < 0.0:
            extracted_gatherers.append(gatherer)
    for gatherer: Unit in extracted_gatherers:
        _extract_gatherer(gatherer)

func _extract_gatherer(unit: Unit) -> void:
    if not current_gatherers.has(unit):
        return # We don't have this in here...
    current_gatherers.erase(unit)
    unit.visible = true
    unit.carrying_item = ResourceItem.Package.new(resourceItem, quantity)
