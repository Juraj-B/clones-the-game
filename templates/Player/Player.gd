extends KinematicBody2D

export (int) var speed = 130
export (int) var jump_speed = -300
export (float, 0, 1.0) var friction = 0.6
export (float, 0, 1.0) var acceleration = 0.9
export (int) var mass = 1
var outside_velocity = Vector2(0, 0)
var gravity
var velocity = Vector2.ZERO
var carrying = false
var carrying_object = null
var movement = true
var snap = 1
var jumping = false

var movable_bodies = []

signal on_screen_exited

func _init():
	add_to_group("player_group")

func _ready():
	gravity = get_parent().get_parent().get("gravity")
	if gravity == null:
		push_error("Parent of the player doesn't have gravity. Please put in a Level2D node. Setting gravity to 1300")
		gravity = 1300
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	emit_signal("on_screen_exited")

func get_input():
	var dir = 0
	if Input.is_action_pressed("move_right"):
		dir += 1
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	elif is_on_floor() or jumping:
		velocity.x = lerp(velocity.x, 0, friction)	


func push():
	for i in get_slide_count():
		var colision = get_slide_collision(i)
		var collider = colision.collider
		if is_instance_valid(collider):
			if collider.is_in_group("physics_bodies"):
#				print(collider)
				if colision.normal.y == 0: #if the normal is horizontal
					velocity.x = (velocity.x * mass) / collider.mass
#					collider.velocity.x = velocity.x
					collider.velocity.x = (velocity.x * mass) / collider.mass
#				if colision.normal.y == 1:
#					velocity.y = velocity.y
#					collider.velocity.y = velocity.y/2
#					velocity.y = velocity.y/2
#					print(collider.velocity.y)
#					print(velocity.y)

func jump_and_push_up():
	if carrying:
		carrying_object.outside_velocity.y = jump_speed
		carrying_object.outside_velocity.x = velocity.x

func _physics_process(delta):
	if movement == true:
			if is_on_floor():
				jumping = false
			velocity.y += gravity * delta
			if get_floor_normal().x != 0:
				velocity.y = 0
			get_input()
			if Input.is_action_just_pressed("move_down"):
				if not is_on_floor():
					velocity.y += -2 * jump_speed
	var bodies = push()
	if Input.is_action_just_pressed("move_jump"):
		if is_on_floor():
			snap = 0
			jumping = true
			velocity.y = jump_speed
			jump_and_push_up()
	if outside_velocity != Vector2.ZERO:
		velocity = outside_velocity
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 10 * snap, Vector2.UP, true)
	outside_velocity = Vector2(0, 0)
	snap = 1

func _on_Area2D_body_entered(body):
	carrying = true
	carrying_object = body

func _on_Area2D_body_exited(body):
	carrying = false
	carrying_object = null
