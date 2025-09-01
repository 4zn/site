extends Node

signal show_message(text: String, duration: float)

var player_ref: Node2D
var current_checkpoint_position: Vector2 = Vector2.ZERO

const DEFAULT_ACTIONS := {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"attack": [MOUSE_BUTTON_LEFT, KEY_J],
	"roll": [KEY_SPACE, KEY_K],
	"interact": [KEY_E]
}

func _ready() -> void:
	_add_default_inputs()
	await get_tree().process_frame
	if player_ref:
		current_checkpoint_position = player_ref.global_position

func _add_default_inputs() -> void:
	for action_name in DEFAULT_ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for code in DEFAULT_ACTIONS[action_name]:
			var ev
			if typeof(code) == TYPE_INT and code >= 1 and code < 512:
				ev = InputEventKey.new()
				ev.keycode = code
				ev.physical_keycode = code
				InputMap.action_add_event(action_name, ev)
			elif code == MOUSE_BUTTON_LEFT or code == MOUSE_BUTTON_RIGHT or code == MOUSE_BUTTON_MIDDLE:
				ev = InputEventMouseButton.new()
				ev.button_index = code
				InputMap.action_add_event(action_name, ev)

func register_player(player: Node2D) -> void:
	player_ref = player
	current_checkpoint_position = player.global_position

func set_checkpoint(pos: Vector2) -> void:
	current_checkpoint_position = pos
	emit_signal("show_message", "Checkpoint reached", 1.5)

func respawn_player() -> void:
	if player_ref:
		player_ref.global_position = current_checkpoint_position
		if "revive" in player_ref:
			player_ref.revive()
		emit_signal("show_message", "You Died", 2.0)