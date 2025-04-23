extends Node

@export var progress_bar: ProgressBar
@export var loading_text: Label

func _on_asset_loader_progress_update(percentage: float, current_index: int, max_index: int) -> void:
    progress_bar.value = percentage
    progress_bar.max_value = 1.0


func _on_asset_loader_loaded_asset(loaded_asset: String) -> void:
    loading_text.text = "Loaded %s" % loaded_asset
