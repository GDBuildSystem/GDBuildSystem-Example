class_name AssetLoader
extends Node

signal on_inform_needs(loader: AssetLoader)
signal on_progress_update(percentage: float, current_index: int, max_index: int)
signal on_loaded_asset(loaded_asset: String)
signal on_start_fully_loaded()
signal on_fully_loaded()

@export var fully_loaded_count_down: float = 2.0 # in seconds
@export var next_scene: PackedScene

var _max_items: PackedStringArray = []
var _loaded_items: PackedStringArray = []
var _queue_loaded_items: PackedStringArray = []
var _count_down: float = fully_loaded_count_down
var _is_loaded: bool = false

func _process(delta: float) -> void:
    # Atomically grab the items.
    var loading_items: PackedStringArray = []
    for asset: String in _queue_loaded_items:
        if not _max_items.has(asset): 
            push_error("Handled a finished loading asset that was not apart of the expected asset loading: %s" % asset)
            continue
        loading_items.append(asset)
    
    # Remove the items that we see this frame.
    for asset: String in loading_items:
        var indx: int = _queue_loaded_items.find(asset)
        if indx == -1:
            continue
        _queue_loaded_items.remove_at(indx)
    
    # Communicate that we loaded these items...
    for asset: String in loading_items: 
        _loaded_items.append(asset)
        on_loaded_asset.emit(asset)
        print("Loaded Asset: %s [%s / %s]" % [asset, _loaded_items.size(), _max_items.size()])
        _update_progress()
    
    # Start and Stop the ticking down before we call that we are done here.
    if _loaded_items.size() == _max_items.size():
        if _count_down == fully_loaded_count_down:
            on_start_fully_loaded.emit()
            print("Started Counting down to finished!")
        _count_down -= delta
        if _count_down <= 0.0 and not _is_loaded:
            print("Finished loading!")
            on_fully_loaded.emit()
            if next_scene:
                get_tree().change_scene_to_packed(next_scene)
            _is_loaded = true
    elif not _is_loaded: # Reset the count-down everytime it is no longer the max == loaded and is still not loaded.
        _count_down = fully_loaded_count_down

func _handle_finished_asset(asset: String) -> void:
    if _queue_loaded_items.has(asset):
        return # Ignore!
    if _is_loaded:
        push_warning("Attempting to load assets while the Asset Loader is considered finished!")
        return # Ignored! 
    _queue_loaded_items.append(asset)

func add_need(expected_string: String) -> void:
    if _max_items.has(expected_string):
        return # Ignore!
    if _is_loaded:
        push_warning("Attempting to add needed assets while the Asset Loader is considered finished!")
        return # Ignored! 
    _max_items.append(expected_string)
    _update_progress()

func _update_progress() -> void:
    var current_index: int = _loaded_items.size()
    var max_size: int = _max_items.size()
    var percentage: float = float(current_index) / float(max_size)
    on_progress_update.emit(percentage, current_index, max_size)
