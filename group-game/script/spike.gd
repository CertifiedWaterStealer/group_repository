extends Area2D

# Specifying the variables type.
var player: CharacterBody2D

var can_interact: bool = false

# When this start, find every node in player the "Player" group and store it into a variable.
func _ready():
	for node in get_tree().get_nodes_in_group("Player"):
		player = node

# Will constantly check if this function can be ran.
func _process(_delta: float) -> void:
	pass

# Once e is pressed and can interact is equal to true gems counter and score counter will go up
# in numbers, with its value being stored in a variable. Then the whole item will disappear.

# Signal checking once a body has entered the area2d and is in player, the can interact boolean
# boolean will get set to true.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_interact = true
	if body == player:
		player._take_damage()
		can_interact = true
