# Ad Maiorem Dei Gloriam!
class_name BoomerangThrower
extends Area2D

@export var projectile_scene: PackedScene
@export var projectile_capacity: int = 1
@export var projectile_count: int = 1
@export var projectile_throw_velocity: float = 500.0

func shoot(direction: Vector2) -> void:
	var projectile: BoomerangProjectile = projectile_scene.instantiate()
	
	projectile.global_position = global_position + direction * 32
	projectile.direction = direction
	projectile.velocity = projectile_throw_velocity
	projectile.target_to_return = self
	
	get_tree().current_scene.add_child(projectile)
	projectile_count -= 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("use") && projectile_count > 0:
		shoot(global_position.direction_to(get_global_mouse_position()))

func _on_body_entered(body: Node2D) -> void:
	if body is BoomerangProjectile && body.returning && body.target_to_return == self:
		body.queue_free()
		projectile_count += 1
