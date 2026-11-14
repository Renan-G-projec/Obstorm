# Ad Maiorem Dei Gloriam!
extends Node2D

@onready var current_weapon: Node2D = get_child(0) as Node2D

func change_weapon(weapon: Node2D) -> void:
	if current_weapon:
		current_weapon.queue_free()
	
	add_child(weapon)
	current_weapon = weapon

func _process(delta: float) -> void:
	current_weapon.casting = Input.is_action_pressed("use")
	
	if current_weapon:
		current_weapon.angle = (current_weapon.get_global_mouse_position() - current_weapon.global_position).angle();
