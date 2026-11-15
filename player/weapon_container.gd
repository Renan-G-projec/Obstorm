# Ad Maiorem Dei Gloriam!
extends Node2D

@onready var current_weapon: Node2D = get_child(0) as Node2D


func _ready() -> void:
	if current_weapon is Laser:
		var tween: Tween = create_tween().set_loops().set_trans(Tween.TRANS_QUAD)
		tween.tween_property($Laser, "color", Color.CYAN, 1.0)
		tween.tween_property($Laser, "color", Color.PURPLE, 1.0)
		tween.tween_property($Laser, "color", Color.GREEN_YELLOW, 1.0)
		tween.tween_property($Laser, "color", Color.YELLOW, 1.0)

func change_weapon(weapon: Node2D) -> void:
	if current_weapon:
		current_weapon.queue_free()
	
	add_child(weapon)
	current_weapon = weapon

func _process(delta: float) -> void:
	
	if current_weapon is Laser:
		current_weapon.casting = Input.is_action_pressed("use")
		current_weapon.angle = (current_weapon.get_global_mouse_position() - current_weapon.global_position).angle();
