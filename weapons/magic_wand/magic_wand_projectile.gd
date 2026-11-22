# Ad Maiorem Dei Gloriam!
class_name MagicWandProjectile
extends Area2D

static var type_data: Dictionary[Type, Dictionary] = {
	Type.FRAGMENTATION: {
		"modulate": Color(0.327, 0.044, 0.348, 1.0),
		"damage": 10.0,
		"fragment_scene": preload("res://weapons/magic_wand/fragmentation_shard.tscn"),
		"damage_of_fragments": 4.0,
		"num_of_fragments": 4,
		"spread": 0.3
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

func _hit_behavior(enemy: EnemyBase) -> void:
	match type:
		Type.FRAGMENTATION:
			var num_fragments: int = type_data[type].num_of_fragments
			var spread: float = type_data[type].spread
			var projectile_scene: PackedScene = type_data[type].fragment_scene
			
			var spread_start = global_rotation - num_fragments / 2 * spread
			for fragment_idx in range(num_fragments):
				var direction_of_fragment = direction.rotated(-(num_fragments / 2) * spread + fragment_idx * spread)
				var projectile: FragmentationShard = projectile_scene.instantiate()
				
				projectile.global_rotation = spread_start + fragment_idx * spread
				projectile.global_position = enemy.global_position
				projectile.origin_body = enemy
				projectile.damage = type_data[type].damage_of_fragments
				projectile.speed = speed * 0.8
				projectile.direction = direction_of_fragment
				
				get_tree().current_scene.add_child(projectile)

func _on_body_entered(body: Node2D) -> void:
	if body is EnemyBase:
		var health_component: HealthComponent = body.get_node_or_null("HealthComponent") as HealthComponent
		if health_component:
			health_component.take_damage(damage)
			_hit_behavior(body)
	queue_free()

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
