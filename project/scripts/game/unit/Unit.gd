class_name Unit
extends CharacterBody2D

signal on_start_carrying(item: ResourceItem.Package)

@export var animated_body: AnimatedSprite2D
@export var action_animation: Dictionary[String, String]
@export var behaviour_priority: Array[UnitBehaviourBase] = []
var carrying_item: ResourceItem.Package = null:
    set(value):
        var previous: ResourceItem.Package = carrying_item
        carrying_item = value
        if previous == null and carrying_item != null:
            on_start_carrying.emit(carrying_item)
var current_behaviour: UnitBehaviourBase

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if current_behaviour == null or current_behaviour.is_nothing_todo():
        for behaviour: UnitBehaviourBase in behaviour_priority:
            if not behaviour.is_nothing_todo():
                current_behaviour = behaviour
                break
    
    if current_behaviour == null:
        return
    
    current_behaviour.process(self, delta)
