extends CharacterBody3D


var SPEED = 5.0
const MOUSE_SENSITIVITY = 0.003

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

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("Ability1") and not usingAbility:
		Ability_Component._activate_ability("Ability1")
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
	
	if Input.is_action_just_pressed("Ability2") and not usingAbility:
		Ability_Component._activate_ability("Ability2")
		usingAbility = true
		await get_tree().create_timer(0.5).timeout
		abilityTimer_timeout()
		
	if Input.is_action_just_pressed("interact") and not usingAbility:
		var collider = raycast.get_collider()
		if collider is Area3D:
			try_interact(collider)

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
		
func _interact_generator(collider) -> void:
	print("gen")
	
func abilityTimer_timeout():
	usingAbility = false
