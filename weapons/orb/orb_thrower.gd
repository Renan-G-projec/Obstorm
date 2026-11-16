# Ad Maiorem Dei Gloriam!
class_name OrbThrower
extends Node2D

@export var projectile: PackedScene
@export var projectile_damage: float = 35.0
@export var projectile_speed: float = 120.0

var _can_shoot: bool = true

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("use") && _can_shoot:
		var projectile: OrbProjectile = projectile.instantiate() as OrbProjectile
		projectile.damage = projectile_damage
		projectile.speed = projectile_speed
		projectile.direction = global_position.direction_to(get_global_mouse_position())
		projectile.global_position = global_position
		get_tree().current_scene.add_child(projectile)
		
		_can_shoot = false
		$Firerate.start()


func _on_firerate_timeout() -> void:
	_can_shoot = true
