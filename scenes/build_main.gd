extends SceneTree
## Scene builder — run: timeout 60 godot --headless --script scenes/build_main.gd

func _initialize() -> void:
	print("Generating: Main")

	var root := Control.new()
	root.name = "Main"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.set_script(load("res://scripts/main_controller.gd"))

	set_owner_on_new_nodes(root, root)

	var count := _count_nodes(root)

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		push_error("Pack failed: " + str(err))
		quit(1)
		return
	if not validate_packed_scene(packed, count, "res://scenes/main.tscn"):
		quit(1)
		return

	err = ResourceSaver.save(packed, "res://scenes/main.tscn")
	if err != OK:
		push_error("Save failed: " + str(err))
		quit(1)
		return

	print("BUILT: %d nodes" % count)
	print("Saved: res://scenes/main.tscn")
	quit(0)

func set_owner_on_new_nodes(node: Node, scene_owner: Node) -> void:
	for child in node.get_children():
		child.owner = scene_owner
		if child.scene_file_path.is_empty():
			set_owner_on_new_nodes(child, scene_owner)

func _count_nodes(node: Node) -> int:
	var total := 1
	for child in node.get_children():
		total += _count_nodes(child)
	return total

func validate_packed_scene(packed: PackedScene, expected_count: int, scene_path: String) -> bool:
	var test_instance = packed.instantiate()
	var actual := _count_nodes(test_instance)
	test_instance.free()
	if actual < expected_count:
		push_error("Pack validation failed for %s: expected %d nodes, got %d" % [scene_path, expected_count, actual])
		return false
	return true
