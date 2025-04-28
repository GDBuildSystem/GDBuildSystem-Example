extends Area2D

@export_group("Editor Debug")
@export var resourceItem: ResourceItem
@export var resourceItem_quantity: int

var item: ResourceItem.Package

func _ready() -> void:
    item = ResourceItem.Package.new(resourceItem, resourceItem_quantity)
