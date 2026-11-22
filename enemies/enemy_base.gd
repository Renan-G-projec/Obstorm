# Ad Maiorem Dei Gloriam!
class_name EnemyBase
extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 40.0
@export var score_on_death: float = 10.0

var _following: bool = true
signal died()

func _ready() -> void:
	var target_position_update_timer: Timer = Timer.new()
	
	target_position_update_timer.autostart = true
	target_position_update_timer.wait_time = 0.3
	target_position_update_timer.timeout.connect(func() -> void: if target: %NavigationAgent2D.target_position = target.global_position)
	
	add_child(target_position_update_timer)
	
	if %Area2D.get_overlapping_bodies().any(func(val: Node2D) -> bool: return val is Player):
		_following = false
	if !target:
		_following = false

func _physics_process(delta: float) -> void:
	if !_following: return
	if %NavigationAgent2D.is_navigation_finished() || !%NavigationAgent2D.is_target_reachable(): return
	
	var next_position: Vector2 = %NavigationAgent2D.get_next_path_position()
	
	var dir: Vector2 = global_position.direction_to(next_position)
	rotation = global_position.direction_to(target.global_position).angle()
	
	velocity = dir * speed;
	move_and_slide()


func _find_nearest_enemy(radius: float, exclude_enemies: Array[EnemyBase]) -> EnemyBase:
	var circle := CircleShape2D.new()
	circle.radius = radius
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0.0, global_position)
	query.collide_with_areas = false
	query.shape = circle
	
	
	var overlapping_bodies: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query)
	var enemies: Array[EnemyBase] = []
	# Enemy filter + self
	for body in overlapping_bodies:
		if body.collider is EnemyBase && body.collider != self && !(body.collider in exclude_enemies): enemies.append(body.collider)
	
	if enemies.is_empty(): return null
	
	return enemies.reduce(
		func(nearest: EnemyBase, compared_enemy: EnemyBase) -> EnemyBase:
			var nearest_dist: float = global_position.distance_squared_to(nearest.global_position)
			var current_dist: float = global_position.distance_squared_to(compared_enemy.global_position)
			return nearest if nearest_dist < current_dist else compared_enemy
	)

func get_chain(enemy_search_radius: float, radius_reduce_factor: float = 0.5, chain_length: int = 3) -> Array[EnemyBase]:
	var ret: Array[EnemyBase] = [self]

	var nearest_enemy: EnemyBase = _find_nearest_enemy(enemy_search_radius, [self])
	
	if !nearest_enemy: return ret
	ret.append(nearest_enemy)
	
	for enemy_index in range(2, chain_length):
		enemy_search_radius *= radius_reduce_factor
		
		nearest_enemy = nearest_enemy._find_nearest_enemy(enemy_search_radius, ret)
		
		if !nearest_enemy: return ret
		ret.append(nearest_enemy)
	
	return ret

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_following = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		_following = true


func _on_health_component_took_damage(damage: float) -> void:
	$FeelComponent.squash_animation(Vector2(0.8, 1.2), 0.3)
	$FeelComponent.hit_animation(0.3)

func _on_health_component_died() -> void:
	died.emit()
	queue_free()
