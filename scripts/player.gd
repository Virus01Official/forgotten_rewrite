extends CharacterBody3D

@export var hitboxes: PackedScene

const WALK_SPEED = 5.0
const SPRINT_SPEED = 9.0
const MOUSE_SENSITIVITY = 0.003

var malice = 1
var is_Killer = true

var current_speed = WALK_SPEED

@onready var camera: Camera3D = $Camera3D
@onready var first_person_cam: Camera3D = $FirstPersonCam
@onready var Ability_Component = $Ability_Component

var usingAbility = false
var equipped_survivor = "chance"
var equipped_killer = "envy"

var stunned = false

var equipped_ability1 = {}
var equipped_ability2 = {}
var equipped_ability3 = {}
var equipped_ability4 = {}

var coins = 0

var pitch: float = 0.0
var cam = false

var health = 100
var maxhealth = 100

var MAX_STAMINA = 100.0
const STAMINA_DRAIN = 25.0   
const STAMINA_RECOVER = 15.0 
const STAMINA_RECOVER_EXHAUSTED = 5 

var stamina: float = MAX_STAMINA
var is_sprinting: bool = false

var exhausted: bool = false       
var sprint_needs_reset: bool = false 

@onready var raycast = $RayCast3D

var weakness = 0
var tokens = 0

var interact_handlers := {
	"generator": _interact_generator,
}

const COOLDOWN_ABILITY1 = 15.0
const COOLDOWN_ABILITY2 = 5.0
const COOLDOWN_ABILITY3 = 5.0
const COOLDOWN_ABILITY4 = 5.0
const COOLDOWN_ATTACK   = 2.0

var cooldowns := {
	"Ability1": 0.0,
	"Ability2": 0.0,
	"Ability3": 0.0,
	"Ability4": 0.0,
	"Attack":   0.0,
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_refresh_abilities()

func _process(delta: float) -> void:
	for key in cooldowns:
		if cooldowns[key] > 0.0:
			cooldowns[key] = max(0.0, cooldowns[key] - delta)

func _is_on_cooldown(action: String) -> bool:
	return cooldowns.get(action, 0.0) > 0.0

func _start_cooldown(action: String, duration: float) -> void:
	cooldowns[action] = duration

func _refresh_abilities() -> void:
	if is_Killer:
		equipped_ability1 = Ability_Component.get_killer_ability("ability1", equipped_killer)
		equipped_ability2 = Ability_Component.get_killer_ability("ability2", equipped_killer)
		if Ability_Component.has_ability("ability3", equipped_killer):
			equipped_ability3 = Ability_Component.get_killer_ability("ability3", equipped_killer)
		if Ability_Component.has_ability("ability4", equipped_killer):
			equipped_ability4 = Ability_Component.get_killer_ability("ability4", equipped_killer)
	else:
		equipped_ability1 = Ability_Component.get_ability_survivor("ability1", equipped_survivor)
		equipped_ability2 = Ability_Component.get_ability_survivor("ability2", equipped_survivor)
		if Ability_Component.has_ability("ability3", equipped_survivor):
			equipped_ability3 = Ability_Component.get_ability_survivor("ability3", equipped_survivor)
		if Ability_Component.has_ability("ability4", equipped_survivor):
			equipped_ability4 = Ability_Component.get_ability_survivor("ability4", equipped_survivor)
			
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_pressed("Sprint") and not exhausted and not sprint_needs_reset:
		is_sprinting = true
	else:
		is_sprinting = false
		
	if weakness > 0:
		$player_ui/GameStuff/VBoxContainer/Label.visible = true
		$player_ui/GameStuff/VBoxContainer/Label.text = "Weakness: " + str(weakness)
		
	$player_ui/GameStuff/Health.value = health

	if Input.is_action_just_pressed("Ability1") and not usingAbility and not _is_on_cooldown(equipped_ability1.get("name", "Ability1")):
		var ability_type = equipped_ability1.get("type", "")
		var ability_name = equipped_ability1.get("name", "Ability1")
		var cooldown_duration = equipped_ability1.get("cooldown", COOLDOWN_ABILITY1)
		Ability_Component._activate_ability(ability_type)
		_start_cooldown(ability_name, cooldown_duration)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()

	if Input.is_action_just_pressed("Ability2") and not usingAbility and not _is_on_cooldown(equipped_ability1.get("name", "Ability2")):
		var ability_type = equipped_ability2.get("type", "")
		var ability_name = equipped_ability2.get("name", "Ability2")
		var cooldown_duration = equipped_ability2.get("cooldown", COOLDOWN_ABILITY2)
		Ability_Component._activate_ability(ability_type)
		_start_cooldown(ability_name, cooldown_duration)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
		
	if Input.is_action_just_pressed("Ability3") and not usingAbility and not equipped_ability3.is_empty() and not _is_on_cooldown(equipped_ability1.get("name", "Ability3")):
		var ability_type = equipped_ability3.get("type", "")
		var ability_name = equipped_ability3.get("name", "Ability3")
		var cooldown_duration = equipped_ability3.get("cooldown", COOLDOWN_ABILITY3)
		Ability_Component._activate_ability(ability_type)
		_start_cooldown(ability_name, cooldown_duration)
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
		
	if Input.is_action_just_pressed("Ability4") and not usingAbility and not equipped_ability4.is_empty() and not _is_on_cooldown(equipped_ability1.get("name", "Ability4")):
		var ability_type = equipped_ability4.get("type", "")
		var ability_name = equipped_ability4.get("name", "Ability4")
		var cooldown_duration = equipped_ability4.get("cooldown", COOLDOWN_ABILITY4)
		Ability_Component._activate_ability(ability_type)
		_start_cooldown(ability_name, cooldown_duration)
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
