extends Node2D


func _ready() -> void:
	var npcs: Array[Node] = get_tree().get_nodes_in_group("npc")

	for npc: Node in npcs:
		var collisions: Array[Node] = npc.find_children(
			"*",
			"CollisionShape2D",
			true,
			false
		)

		for collision: Node in collisions:
			collision.queue_free()
