extends Node

@export var next_scene: PackedScene

func on_start_fully_loaded() -> void:
    get_tree().change_scene_to_packed(next_scene)

func on_inform_needs(loader: AssetLoader) -> void:
    loader.add_need(next_scene.resource_path)
