extends CharacterBody2D

signal health_changed(current: int, max: int)

@export var max_health: int = 60
@export var move_speed: float = 160.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.8
@export var detection_range: float = 260.0
@export var attack_range: float = 28.0

var current_health: int
var last_attack_time: float = 0.0

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(_delta: float) -> void:
	if not Game.player_ref:
		return
	var to_player := Game.player_ref.global_position - global_position
	var dist := to_player.length()
	if dist > detection_range:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if dist > attack_range:
		velocity = to_player.normalized() * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		_try_attack()

func _try_attack() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < attack_cooldown:
		return
	last_attack_time = now
	hitbox.monitoring = true
	await get_tree().create_timer(0.1).timeout
	hitbox.monitoring = false

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health, max_health)
	if current_health <= 0:
		queue_free()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player") and "take_damage" in body:
		body.take_damage(attack_damage)