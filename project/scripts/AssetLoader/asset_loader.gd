class_name AssetLoader
extends Node

signal on_inform_needs(loader: AssetLoader)
signal on_progress_update(percentage: float, current_index: int, max_index: int)
signal on_loaded_asset(loaded_asset: String)
signal on_start_fully_loaded()
signal on_fully_loaded()

class ThreadedAsset:
    var path: String
    var progress: float
    var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS
    var result: Variant
    
    func _init(_path: String) -> void:
        path = _path
    
    func _update() -> void:
        if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
            if result != null:
                progress = 1.0
            return # We are no longer in progress.
        var _progress: Array = []
        status = ResourceLoader.load_threaded_get_status(path, _progress)
        if _progress.size() > 0:
            progress = _progress[0]
        if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
            result = ResourceLoader.load_threaded_get(path)
        var status_str: String = "Unknown"
        match status:
            ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
                status_str = "Failed"
            ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
                status_str = "Invalid Resource"
            ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
                status_str = "In Progress"
            ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
                status_str = "Loaded"
        print("Loading Resource: %s [%s - %s]" % [path, progress, status_str])
        

@export var fully_loaded_count_down: float = 2.0 # in seconds

var _max_items: PackedStringArray = []
var _threaded_items: Dictionary[String, ThreadedAsset] = {}
var _loaded_items: PackedStringArray = []
var _queue_loaded_items: PackedStringArray = []
var _count_down: float = fully_loaded_count_down
var _is_loaded: bool = false

func _ready() -> void:
    _deferred_needs.call_deferred()

func _deferred_needs() -> void:
    on_inform_needs.emit(self)

func _process(delta: float) -> void:
    _handle_asset_loading()
    _handle_item_loading(delta)

func _handle_asset_loading() -> void:
    for item: String in _threaded_items:
        var asset: ThreadedAsset = _threaded_items[item]
        var was_loading: bool = asset.status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS
        asset._update()
        if asset.status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS and was_loading:
            var status_str: String = "Unknown"
            match asset.status:
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
                    status_str = "Failed"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
                    status_str = "Invalid Resource"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
                    status_str = "In Progress"
                ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
                    status_str = "Loaded"
            if asset.status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
                _handle_finished_asset(asset.path)
            else:
                push_error("An error happened while loading a Threaded Asset: %s [%s]" % [asset.path, status_str])
func _handle_item_loading(delta: float) -> void:
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
    print("Added Expected Asset Resource To Be loaded: %s" % expected_string)
    _max_items.append(expected_string)
    if ResourceLoader.exists(expected_string): # If this is a resource file that we can asynchronously load, then we will.
        ResourceLoader.load_threaded_request(expected_string)
        _threaded_items[expected_string] = ThreadedAsset.new(expected_string)
        print("\tAdded Threaded Resource: %s" % expected_string)
    _update_progress()

func _update_progress() -> void:
    var current_index: int = _loaded_items.size()
    var max_size: int = _max_items.size()
    var percentage: float = float(current_index) / float(max_size)
    on_progress_update.emit(percentage, current_index, max_size)
