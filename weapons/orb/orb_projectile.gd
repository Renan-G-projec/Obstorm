# Ad Maiorem Dei Gloriam!
class_name OrbProjectile
extends StaticBody2D

var damage: float = 25.0
var direction: Vector2 = Vector2.RIGHT
var speed: float = 150.0

var bounces_to_free: int = 4:
	set(val):
		bounces_to_free = val
		if (val <= 0):
			queue_free()

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(direction * delta * speed)
	if collision:
		var collider: EnemyBase = collision.get_collider() as EnemyBase
		if collider:
			var health_component: HealthComponent = collider.get_node_or_null("HealthComponent") as HealthComponent
			if health_component:
				health_component.take_damage(damage)
			queue_free()
		else:
			direction = direction.bounce(collision.get_normal())
			bounces_to_free -= 1


func _on_lifetime_timeout() -> void:
	queue_free()
