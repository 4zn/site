extends CanvasLayer

@onready var health_bar: TextureProgressBar = $Margin/HBox/Health
@onready var stamina_bar: TextureProgressBar = $Margin/HBox/Stamina
@onready var message_label: Label = $Margin/VBox/Message

func _ready() -> void:
	if Game.player_ref:
		_connect_player(Game.player_ref)
	Game.connect("show_message", Callable(self, "_on_show_message"))

func _process(_delta: float) -> void:
	if Game.player_ref and not health_bar.is_connected("value_changed", Callable(self, "_noop")):
		_connect_player(Game.player_ref)

func _connect_player(player: Node) -> void:
	if not player.is_connected("health_changed", Callable(self, "_on_health_changed")):
		player.connect("health_changed", Callable(self, "_on_health_changed"))
	if not player.is_connected("stamina_changed", Callable(self, "_on_stamina_changed")):
		player.connect("stamina_changed", Callable(self, "_on_stamina_changed"))

func _on_health_changed(current: int, max_value: int) -> void:
	health_bar.max_value = max_value
	health_bar.value = current

func _on_stamina_changed(current: float, max_value: float) -> void:
	stamina_bar.max_value = max_value
	stamina_bar.value = current

func _on_show_message(text: String, duration: float) -> void:
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(duration).timeout
	if message_label.text == text:
		message_label.visible = false

func _noop(_value):
	pass