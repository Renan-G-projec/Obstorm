# Ad Maiorem Dei Gloriam!
class_name MagicWand
extends Node2D

@export var projectile: PackedScene
@export var projectile_speed: float = 200.0
@export var projectile_type: MagicWandProjectile.Type

func _ready() -> void:
	assert(projectile, "Error: No projectile configured to wand.")

func _physics_process(delta: float) -> void:
	global_rotation = global_position.direction_to(get_global_mouse_position()).angle()
	if Input.is_action_just_pressed("use"):
		shoot()

func shoot() -> void:
	var projectile_instance: MagicWandProjectile = projectile.instantiate() as MagicWandProjectile
	assert(projectile_instance is MagicWandProjectile, "Error: Projectile of the magic wand NEEDS to be of MagicWandProjectile class.")
	
	projectile_instance.speed = projectile_speed
	projectile_instance.type = projectile_type
	projectile_instance.direction = Vector2.RIGHT.rotated(global_rotation)
	projectile_instance.global_position = $Marker2D.global_position
	
	get_tree().root.add_child(projectile_instance)
