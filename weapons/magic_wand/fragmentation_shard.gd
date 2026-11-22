# Ad Maiorem Dei Gloriam!
class_name FragmentationShard
extends Area2D

var damage: float = 2.0
var origin_body: Node2D
var speed: float = 50.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	for body in get_overlapping_bodies():
		if body != origin_body: _try_attack_body(body)
	
func _on_lifetime_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body != origin_body: _try_attack_body(body)

func _try_attack_body(body: Node2D) -> void:
	if body is EnemyBase:
		var health_component: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			health_component.take_damage(2.0)
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed
