# Ad Maiorem Dei Gloriam!
class_name MagicWandProjectile
extends Area2D

static var type_data: Dictionary[Type, Dictionary] = {
	Type.FRAGMENTATION: {
		"modulate": Color(0.327, 0.044, 0.348, 1.0),
		"damage": 10.0,
		"damage_of_fragments": 4.0
	},
	Type.FIRE: {
		"modulate": Color(0.417, 0.0, 0.0, 1.0),
		"damage": 8.0,
		"burning_dps": 2.0,
		"burning_time": 1.5
	},
	Type.ELETRIC: {
		"modulate": Color(0.031, 0.353, 0.467, 1.0),
		"damage": 12.0,
		"paralisys_chance": 0.25
	}
} 

enum Type {
	FRAGMENTATION,
	FIRE,
	ELETRIC
}

var damage: float = 0.0
var speed: float = 200.0
var direction: Vector2

var type: Type:
	set(val):
		if val == type: return
		type = val
		
		_sync_with_type()

func _ready() -> void:
	_sync_with_type()

func _physics_process(delta: float) -> void:
	global_position += delta * direction * speed

func _sync_with_type() -> void:
	modulate = type_data[type].get("modulate", Color.WHITE)
	damage = type_data[type].get("damage", 10.0)

func _hit_behavior() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is EnemyBase:
		var health_component: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			health_component.take_damage(damage)
			_hit_behavior()
	queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
