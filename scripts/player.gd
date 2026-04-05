extends CharacterBody3D

@export var hitboxes: PackedScene

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const MOUSE_SENSITIVITY = 0.003

var malice = 1
var is_Killer = false

var current_speed = WALK_SPEED

@onready var camera: Camera3D = $Camera3D
@onready var first_person_cam: Camera3D = $FirstPersonCam
@onready var Ability_Component = $Ability_Component

var usingAbility = false
var equipped_survivor = "chance"
var equipped_killer = "Test"

var equipped_ability1 = ""
var equipped_ability2 = ""

var coins = 0

var pitch: float = 0.0
var cam = false

var MAX_STAMINA = 100.0
const STAMINA_DRAIN = 25.0   
const STAMINA_RECOVER = 15.0 
const STAMINA_RECOVER_EXHAUSTED = 5 

var stamina: float = MAX_STAMINA
var is_sprinting: bool = false

var exhausted: bool = false       
var sprint_needs_reset: bool = false 

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
		
		equipped_ability1 = Ability_Component.get_ability_survivor("ability1", equipped_survivor)

	if Input.is_action_just_pressed("Ability1") and not usingAbility and not _is_on_cooldown(equipped_ability1):
		Ability_Component._activate_ability(equipped_ability1)
		_start_cooldown(equipped_ability1, COOLDOWN_ABILITY1)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
		
	if Input.is_action_pressed("Sprint") and not exhausted and not sprint_needs_reset:
		is_sprinting = true
	else:
		is_sprinting = false

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
			
	if Input.is_action_just_pressed("ChangeCam"):
		cam = not cam
		if cam:
			$FirstPersonCam.current = true
		else:
			camera.current = true

	if Input.is_action_just_pressed("Attack") and not usingAbility and not _is_on_cooldown("Attack") and is_Killer:
		_start_cooldown("Attack", COOLDOWN_ATTACK)
		usingAbility = true
		Ability_Component._activate_ability("slash")
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
		
	if is_sprinting:
		current_speed = SPRINT_SPEED
		stamina = max(stamina - STAMINA_DRAIN * delta, 0.0)
	else:
		if exhausted:
			stamina = min(stamina + STAMINA_RECOVER_EXHAUSTED * delta, MAX_STAMINA)
			if stamina >= MAX_STAMINA * 0.25:
				exhausted = false
		else:
			stamina = min(stamina + STAMINA_RECOVER * delta, MAX_STAMINA)

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
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
		first_person_cam.rotation.x = pitch

func _interact_generator(_collider) -> void:
	print("gen")

func abilityTimer_timeout():
	usingAbility = false
