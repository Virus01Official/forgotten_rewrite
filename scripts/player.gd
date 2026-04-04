extends CharacterBody3D

@export var hitboxes: PackedScene

var SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003

var malice = 1
var is_Killer = false

@onready var camera: Camera3D = $Camera3D
@onready var Ability_Component = $Ability_Component

var usingAbility = false
var equippedAbilityOne = "Test"
var equippedAbilityTwo = "Test"

var pitch: float = 0.0

var MAX_STAMINA = 100.0
var stamina: float = MAX_STAMINA
var is_sprinting: bool = false

@onready var raycast = $RayCast3D

var interact_handlers := {
	"generator": _interact_generator,
}

const COOLDOWN_ABILITY1 = 3.0
const COOLDOWN_ABILITY2 = 5.0
const COOLDOWN_ATTACK   = 2.0

var cooldowns := {
	"Ability1": 0.0,
	"Ability2": 0.0,
	"Attack":   0.0,
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	for key in cooldowns:
		if cooldowns[key] > 0.0:
			cooldowns[key] = max(0.0, cooldowns[key] - delta)

func _is_on_cooldown(action: String) -> bool:
	return cooldowns.get(action, 0.0) > 0.0

func _start_cooldown(action: String, duration: float) -> void:
	cooldowns[action] = duration

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Ability1") and not usingAbility and not _is_on_cooldown("Ability1"):
		Ability_Component._activate_ability("Ability1")
		_start_cooldown("Ability1", COOLDOWN_ABILITY1)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()

	if Input.is_action_just_pressed("Ability2") and not usingAbility and not _is_on_cooldown("Ability2"):
		Ability_Component._activate_ability("Ability2")
		_start_cooldown("Ability2", COOLDOWN_ABILITY2)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()

	if Input.is_action_just_pressed("interact") and not usingAbility:
		var collider = raycast.get_collider()
		if collider is Area3D:
			try_interact(collider)

	if Input.is_action_just_pressed("Attack") and not usingAbility and not _is_on_cooldown("Attack"):
		_start_cooldown("Attack", COOLDOWN_ATTACK)
		usingAbility = true
		Ability_Component._activate_ability("slash")
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func try_interact(collider: Area3D):
	if not is_multiplayer_authority():
		return
	for group in interact_handlers.keys():
		if collider.is_in_group(group):
			interact_handlers[group].call(collider)
			return

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = pitch

func _interact_generator(_collider) -> void:
	print("gen")

func abilityTimer_timeout():
	usingAbility = false
