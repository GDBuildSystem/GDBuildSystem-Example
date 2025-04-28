extends Resource
class_name ResourceItem

class Package:
    var item: ResourceItem
    var quantity: int
    
    func _init(_item: ResourceItem, _quantity: int = 1) -> void:
        item = _item.duplicate(true)
        quantity = _quantity

@export var name: String
@export var prefab: PackedScene
@export var static_icon: Texture2D
