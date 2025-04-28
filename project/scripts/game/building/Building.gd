class_name Building
extends AnimatedSprite2D

@export var behaviours: Array[BuildingBehaviour]
@export_group("Mechanics")
@export var cost: Dictionary[ResourceItem, int] = {}
@export_group("Animations")
@export var idle_animation: String = "default"
@export var construction_animation: String = "construction"
@export var damaged_animation: String = "damaged"
@export var death_animation: String = "death"
@export var death_idle_animation: String = "death"

var team_id: int
