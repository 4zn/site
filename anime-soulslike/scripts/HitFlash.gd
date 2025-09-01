extends Node

@export var target_path: NodePath
@export var flash_color: Color = Color(1, 0.2, 0.6)
@export var duration: float = 0.1

var original_color: Color

func flash() -> void:
	var node := get_node_or_null(target_path)
	if node and node is Polygon2D:
		var poly := node as Polygon2D
		if original_color == Color(0,0,0,0):
			original_color = poly.color
		poly.color = flash_color
		await get_tree().create_timer(duration).timeout
		poly.color = original_color