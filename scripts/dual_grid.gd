@tool
extends Node2D

const SOURCE_ID := 0
const GRASS_ATLAS := Vector2i(2, 1)  
const DIRT_ATLAS := Vector2i(0, 3)   


const MASK_TO_ATLAS := {
	0: Vector2i(0, 3),
	1: Vector2i(1, 3),
	2: Vector2i(0, 0),
	3: Vector2i(3, 0),
	4: Vector2i(0, 2),
	5: Vector2i(1, 0),
	6: Vector2i(2, 3),
	7: Vector2i(1, 1),
	8: Vector2i(3, 3),
	9: Vector2i(0, 1),
	10: Vector2i(3, 2),
	11: Vector2i(2, 0),
	12: Vector2i(1, 2),
	13: Vector2i(2, 2),
	14: Vector2i(3, 1),
	15: Vector2i(2, 1),
}

var world: TileMapLayer
var display: TileMapLayer


func _ready() -> void:
	world = get_node_or_null("World")
	display = get_node_or_null("Display")
	if world == null or display == null:
		push_warning("Faltan los nodos hijos 'World' y 'Display'.")
		return

	if not world.changed.is_connected(refresh):
		world.changed.connect(refresh)

	# En el juego se esconde la capa de pintar; en el editor se ve tenue.
	if Engine.is_editor_hint():
		world.self_modulate = Color(1, 1, 1, 0.3)
	else:
		world.visible = false

	refresh()


func _is_grass(cell: Vector2i) -> bool:
	return world.get_cell_source_id(cell) != -1 \
		and world.get_cell_atlas_coords(cell) == GRASS_ATLAS


func refresh() -> void:
	if world == null or display == null:
		return
	display.clear()

	# Cada celda del mundo afecta a 4 tiles visuales.
	var to_update := {}
	for cell in world.get_used_cells():
		to_update[cell] = true
		to_update[cell + Vector2i(1, 0)] = true
		to_update[cell + Vector2i(0, 1)] = true
		to_update[cell + Vector2i(1, 1)] = true

	for d in to_update:
		var mask := 0
		if _is_grass(d + Vector2i(-1, -1)): mask |= 8
		if _is_grass(d + Vector2i(0, -1)):  mask |= 4
		if _is_grass(d + Vector2i(-1, 0)):  mask |= 2
		if _is_grass(d):                    mask |= 1
		display.set_cell(d, SOURCE_ID, MASK_TO_ATLAS[mask])
