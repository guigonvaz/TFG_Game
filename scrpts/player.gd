extends CharacterBody2D

const speed = 120
var direction = 0.0
const jump = 250
const gravity = 10

var wall_grab = false
var wall_jump_allowed = false
const wall_slide_speed = 20.0
const wall_jump_force = Vector2(200, 170)
var wall_jump_timer = 0.0
const wall_jump_gravity_delay = 0.15 # segundos sin gravedad después de saltar

var is_alive = true
var took_damage = false

@onready var anim := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var ray_left := $WallCheckLeft
@onready var ray_right := $WallCheckRight

func _ready() -> void:
	# Añadir al grupo 'player' para que Peligro lo detecte
	if not is_in_group("player"):
		add_to_group("player")


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	## Detectar muerte por trampa/peligro
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider != null and collider.is_in_group("danger"):
			die()
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	direction =  Input.get_axis("move_left", "move_right")
	
	# --- DETECTAR PARED ---
	var touching_wall_left = ray_left.is_colliding()
	var touching_wall_right = ray_right.is_colliding()
	var touching_wall = touching_wall_left or touching_wall_right
	
	# --- AGARRE A PARED ---
	if not is_on_floor():
		if Input.is_action_pressed("interact") and touching_wall: # tu tecla E
			wall_grab = true
			velocity.y = 0  # se queda pegado
			if Input.is_action_pressed("move_up"):
				velocity.y = -speed / 2
			elif Input.is_action_pressed("move_down"):
				velocity.y = speed / 2
			else:
				velocity.y = 0

		elif not Input.is_action_pressed("interact") or not touching_wall:
			wall_grab = false
	else:
		wall_grab = false
	
	# --- MOVIMIENTO HORIZONTAL ---
	if not wall_grab:
		velocity.x = direction * speed
	else:
		velocity.x = 0

	# --- SALTO NORMAL ---
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump

	# --- WALL JUMP ---
	if touching_wall and Input.is_action_just_pressed("jump"):
		wall_grab = false
		wall_jump_allowed = true
		
		# Detectar de qué lado está la pared realmente (rayos)
		var jump_dir = 0
		if ray_left.is_colliding():
			jump_dir = 1   # pared izquierda → salto hacia la derecha
		elif ray_right.is_colliding():
			jump_dir = -1  # pared derecha → salto hacia la izquierda

		# Aplicar impulso de salto en pared
		velocity.x = jump_dir * wall_jump_force.x
		velocity.y = -wall_jump_force.y

		# Pequeño delay sin gravedad para que se sienta más "potente"
		wall_jump_timer = wall_jump_gravity_delay

	# --- GRAVEDAD / DESLIZAMIENTO ---
	if not is_on_floor() and not wall_grab and wall_jump_timer <= 0:
		velocity.y += gravity
		
	move_and_slide()

	# --- ANIMACIÓN ---
	if wall_grab:
		anim.play("idle")
	elif is_on_floor():
		if direction != 0:
			anim.play("idle")
		else:
			anim.play("idle")
	else:
		anim.play("idle")
		
	sprite.flip_h = direction < 0 if direction !=0 else sprite.flip_h

func die() -> void:
	if not is_alive:
		return # evita que se ejecute dos veces
	
	is_alive = false
	# anim.play("death") # si tienes una animación de muerte
	set_physics_process(false) # desactiva movimiento temporal
	
	# Espera un momento y reinicia la escena
	await get_tree().create_timer(0.7).timeout
	get_tree().reload_current_scene()
	
