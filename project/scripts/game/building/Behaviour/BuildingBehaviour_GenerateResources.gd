class_name BuildingBehaviour_GenerateResource
extends BuildingBehaviour

@export var item: ResourceItem
@export var tick_amount: int = 3
@export var tick_interval: float = 1.0
@export var start_amount: int = 0
@export var limited_amount: int = 100
@export var revive_delay: float = -1.0

func start() -> void:
    pass
