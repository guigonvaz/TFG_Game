extends CharacterBody2D

# --- Parámetros ---
@export var gravity := 900        # fuerte
@export var jump_force := Vector2(100, -250)
@export var jump_interval := 2.0
@export var move_direction := 1  # 1 derecha, -1 izquierda

var jump_lock_time := 0.0
const JUMP_LOCK_DURATION := 0.12

# --- Nodos ---
@onready var sprite := $Sprite2D
@onready var jump_timer := $JumpTimer
@onready var ray_floor := $RayFloor
@onready var ray_wall := $RayWall


func _ready():
	jump_timer.wait_time = jump_interval
	jump_timer.start()

func _physics_process(delta):
	if jump_lock_time > 0.0:
		jump_lock_time -= delta
		if jump_lock_time < 0.0:
			jump_lock_time = 0.0

	# ---- Gravedad ----
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if jump_lock_time <= 0.0:
			velocity.x = 0

	# ---- Detección de pared ----
	if ray_wall.is_colliding():
		if jump_lock_time <= 0.0:
			move_direction *= -1
			if (move_direction < 0):
				ray_wall.rotation = PI
			else:
				ray_wall.rotation = 0
			sprite.flip_h = move_direction < 0

	move_and_slide()


# ---- Saltar automáticamente ----
func _on_JumpTimer_timeout():
	if ray_floor.is_colliding() or is_on_floor():
		velocity.y = jump_force.y
		velocity.x = move_direction * jump_force.x
		jump_lock_time = JUMP_LOCK_DURATION
	jump_timer.start()
