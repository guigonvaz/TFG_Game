extends CharacterBody2D

const speed = 120
var direction = 0.0
const jump = 250
const gravity = 10

@onready var anim := $AnimationPlayer
@onready var sprite := $Sprite2D
func _physics_process(delta: float) -> void:
	direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	if direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")
	sprite.flip_h = direction < 0 if direction !=0 else sprite.flip_h
		
	# Con el is_action_just_pressed conseguimos que salte en onclik (mantener no vale)
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"): #
		velocity.y -= jump
	if !is_on_floor():
		velocity.y += gravity
		
	move_and_slide()
