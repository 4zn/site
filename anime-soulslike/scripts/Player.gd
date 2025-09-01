extends CharacterBody2D

signal health_changed(current: int, max: int)
signal stamina_changed(current: float, max: float)

@export var move_speed: float = 220.0
@export var roll_speed: float = 420.0
@export var roll_duration: float = 0.25
@export var stamina_max: float = 100.0
@export var stamina_regen_per_sec: float = 25.0
@export var roll_stamina_cost: float = 25.0
@export var attack_stamina_cost: float = 20.0
@export var max_health: int = 100
@export var attack_damage: int = 20
@export var attack_cooldown: float = 0.5

var current_health: int
var current_stamina: float
var is_attacking: bool = false
var is_rolling: bool = false
var look_dir: Vector2 = Vector2.RIGHT

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	current_health = max_health
	current_stamina = stamina_max
	Game.register_player(self)
	emit_signal("health_changed", current_health, max_health)
	emit_signal("stamina_changed", current_stamina, stamina_max)
	add_to_group("player")
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if is_attacking or is_rolling:
		move_and_slide()
		return

	var input_dir := _get_input_direction()
	if input_dir.length() > 0.0:
		look_dir = input_dir.normalized()
	velocity = input_dir * move_speed
	move_and_slide()

func _process(delta: float) -> void:
	if not is_attacking and not is_rolling:
		current_stamina = min(stamina_max, current_stamina + stamina_regen_per_sec * delta)
		emit_signal("stamina_changed", current_stamina, stamina_max)

	if Input.is_action_just_pressed("attack"):
		_attack()
	elif Input.is_action_just_pressed("roll"):
		_roll()

func _get_input_direction() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	return dir.normalized()

func _attack() -> void:
	if is_attacking or is_rolling:
		return
	if current_stamina < attack_stamina_cost:
		return
	is_attacking = true
	current_stamina -= attack_stamina_cost
	emit_signal("stamina_changed", current_stamina, stamina_max)
	_hitbox_reposition()
	hitbox.monitoring = true
	await get_tree().create_timer(0.12).timeout
	hitbox.monitoring = false
	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false

func _roll() -> void:
	if is_attacking or is_rolling:
		return
	if current_stamina < roll_stamina_cost:
		return
	is_rolling = true
	current_stamina -= roll_stamina_cost
	emit_signal("stamina_changed", current_stamina, stamina_max)
	var roll_velocity := look_dir.normalized() * roll_speed
	velocity = roll_velocity
	await get_tree().create_timer(roll_duration).timeout
	is_rolling = false

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health, max_health)
	if current_health <= 0:
		Game.respawn_player()

func revive() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func _hitbox_reposition() -> void:
	var offset := look_dir.normalized() * 20.0
	$Hitbox.position = offset
	$Hitbox.rotation = look_dir.angle()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and "take_damage" in body:
		body.take_damage(attack_damage)