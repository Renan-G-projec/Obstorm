# Ad Maiorem Dei Gloriam!
class_name BoomerangProjectile
extends StaticBody2D

const RETURN_ACCELLERATION = 250

var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var velocity: float = 0.0
var target_to_return: Node2D = null
var returning: bool = false
var hitten_enemies: Array[EnemyBase]

const _PLAYER_LAYER = 1

func _physics_process(delta: float) -> void:
	if !target_to_return: 
		queue_free()
		return
	rotation += delta * velocity
	
	var target_direction: Vector2 = global_position.direction_to(target_to_return.global_position)
	direction = direction.lerp(target_direction, 0.25 if returning else 0.05)
	
	if abs(direction.angle_to(target_direction)) < PI / 2:
		if !returning:
			hitten_enemies.clear()
			returning = true 
			set_collision_mask_value(_PLAYER_LAYER, false)

	if move_and_collide(direction * delta * velocity):
		direction = target_direction


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is EnemyBase && !(body in hitten_enemies):
		hitten_enemies.append(body)
		var health_component: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			health_component.take_damage(damage)
