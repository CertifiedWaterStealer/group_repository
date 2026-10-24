extends CharacterBody2D

# Intially set to true 
var dash_cooldown_timer_is_ready: bool = true 

# Vector2 is stored in movement
var movement = Vector2()

# Healht is a number and it's set to 10
var health: int = 3

# constantly set to 200.0 
const SPEED = 1300.0

# Constantly set to 400.0
const SPRINT_SPEED: float = 400.0

# constantly set to 300.0
const WALK_SPEED: float = 300.0

# constantly set the 450.0
const DASH_SPEED: float = 2000.0

# A number that can go up or down stored in dahs key pressed.
var dash_key_pressed: int = 0

# Boolean set to false.
var is_dashing = false
 
# boolean set to true.
var facing_right = true

# The total amount the player can perform, holding an amount.
var total_dashes: int = 1

# constly set to 600.0.
const GRAVITY: float = 1300.0

# constantly set to 170.0.
const JUMP_SPEED: float = 800.0

# Constantly set to 400.0.
const JUMP_ACCELERATION: float = 1400.0

# Set to a total of 2 .
var total_jumps: int = 2 

# stored 200.0 .
var wall_jump_force_x = 800.0

# stored -200.0.
var wall_jump_force_y = -800.0

# intially equaling false.
var is_wall_jumping: bool = false

# once the game starts it finds the node and stores it.
@onready var left_raycast: RayCast2D = $Node2D/LeftRayCast2D

# once the game starts it finds the node and stores it.
@onready var right_raycast: RayCast2D = $Node2D/RightRayCast2D2

@export var player = CollisionShape2D

# When this start, find every node in player the "Player" group and store it into a variable.
func _ready():
	pass

# This runs repeatidly, handling the physics and physics related functions. 'delta' 
# is the time since the previous frame. I multiply my 'GRAVITY' constant with my 
# 'delta' perameter. 'velocity.y' is a 'Vector2' in the y axis. So summarised, 
# I am multiplying my 'GRAVITY' constant with my delta parameter, then plusing this 
# with 'velocity.y'. 
func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	_horizontal_movement()
	_jump()
	_wall_slide()
	_animations()
	_animation_flip()
	move_and_slide()

# gets the input direction and handle the movement/deceleration. The 'lerp' function is
# used to create a smooth transition between the two values overtime. 
func _horizontal_movement():
	if is_wall_jumping == false and is_dashing == false:
		movement = Input.get_axis("a_key", "d_key")
		if movement:
			velocity.x = movement * SPEED
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.2)

# checking multiple things then the player can use the dash function and if they are attcking
# then they cannot.
	if Input.is_action_just_pressed("q_key") and dash_key_pressed == 0 and total_dashes >= 1:
		total_dashes -= 1
		dash_key_pressed = 1
		_dash()

# Handles the character's jump. This first section checks if the player is on the floor.
# If they are, then the player is capable of jumping. 
func _jump():
	if is_on_floor():
		total_dashes = 1
		total_jumps = 2
		if Input.is_action_just_pressed("w_key"):
			total_jumps -= 1 
			velocity.y -= lerp(JUMP_SPEED, JUMP_ACCELERATION, 0.1)

# This second part of the jump function, handles the player's double jumping ability.
# If the player is not on the floor, then they can jump. Then the 'return' will bring
# it back to the first line in the function.
	if not is_on_floor():
		if total_jumps > 0:
			if Input.is_action_just_pressed("w_key"):
				total_jumps -= 1
				velocity.y -= lerp(JUMP_SPEED, JUMP_ACCELERATION, 0.1)
	else:
		return

# Made to give the player the ability to move quickly in a short burst with cooldown funcs
# being ran to give a cooldown, and different sotred variables to give the constant numbers
#needed for this.
func _dash():
	if dash_key_pressed == 1:
		is_dashing = true
	else:
		is_dashing = false
	if facing_right:
		velocity.x = DASH_SPEED
		_dash_cooldown()
	if facing_right == false:
		velocity.x = -DASH_SPEED
		_dash_cooldown()

# func providing the cooldown so the player cannot spam it constantly by using a timer and boolean.
# and then returning it to check again. 
func _dash_cooldown():
	if is_dashing == true:
		dash_key_pressed = 1
		await get_tree().create_timer(0.2).timeout
		is_dashing = false
		dash_key_pressed = 0
	else:
		return

# This automatically sets the player's 'velocity.y' to 10, 'if' they are touching a wall
# for 'velocity.y', if the number is positive, that means there going down. When it is
# negative, they will move upwards.
func _wall_slide():
	if is_on_wall_only():
		velocity.y = 10
		if Input.is_action_just_pressed("w_key"):
			if left_raycast.is_colliding():
				total_jumps = 1
				velocity = Vector2(wall_jump_force_x, wall_jump_force_y) 
				_inputting_wall_jump()
			if right_raycast.is_colliding():
				total_jumps = 1
				velocity = Vector2(-wall_jump_force_x, wall_jump_force_y)
				_inputting_wall_jump()

# Adding a cooldown so the player cannot spam the button.
func _inputting_wall_jump():
	is_wall_jumping = true
	await get_tree().create_timer(0.2).timeout
	is_wall_jumping = false

func _take_damage():
	health -= 1
	print(health)

# Made to play the animation when the player's 'velocity.x' is not equal to zero, or
# when the velocity is equal to zero. Fror 'velocity.x' the numbers are oppisite to
# 'velocity.y'.  
func _animations():
	pass

func _animation_flip():
	if velocity.x > 0:
		facing_right = true
		$CollisionShape2D.scale.x = 1
	if velocity.x < 0:
		facing_right = false
		$CollisionShape2D.scale.x = -1
