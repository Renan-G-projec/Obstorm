# Ad Maiorem Dei Gloriam!
@tool
class_name Laser
extends RayCast2D


@export var damage: float = 5
@export var color: Color = Color(0.0, 0.776, 0.82, 1.0): set = _on_color_changed
@export var casting: bool = true: set = _on_casting_changed
@export var laser_bounce_quantity: int = 3
@export var laser_max_length: float = 720
@export var laser_length: float = laser_max_length: set = _on_laser_length_changed
@export var laser_width: float = 2.0
@export var angle: float = 0.0:
	set(val):
		angle = val
		target_position = (Vector2.RIGHT * laser_max_length).rotated(angle);
		%Line2D.set_point_position(1, (Vector2.RIGHT * laser_length).rotated(angle))

@onready var damage_rate_timer: Timer = $DamageRateTimer

var _chain_of_entities: Array[Node2D]
var _chain_invencible: bool = false
var _fade_tween: Tween

func _on_color_changed(new_color: Color) -> void:
	color = new_color
	modulate = new_color

func _on_casting_changed(new_casting: bool) -> void:
	if new_casting == casting: return
	
	casting = new_casting
	set_physics_process(casting)
	if casting:
		_fade_in()
	else:
		_fade_out()

func _on_laser_length_changed(new_length: float) -> void:
	if (new_length == laser_length): return
	
	laser_length = new_length
	
	$CPUParticles2D.position = target_position.normalized() * new_length
	%Line2D.set_point_position(1, target_position.normalized() * new_length)

func _fade_out() -> void:
	_chain_of_entities.clear()
	
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
	laser_length = laser_max_length
	$CPUParticles2D.emitting = false
	
	_fade_tween.tween_property(%Line2D, "width", 0, 0.2)

func _fade_in() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
	await _fade_tween.tween_property(%Line2D, "width", laser_width, 0.2).finished
	

func _physics_process(delta: float) -> void:
	if !is_colliding(): 
		laser_length = laser_max_length
		$CPUParticles2D.emitting = false
	else:
		laser_length = (global_position - get_collision_point()).length()
		$CPUParticles2D.emitting = true
		$CPUParticles2D.direction = get_collision_normal()
		
		var collider: EnemyBase = get_collider() as EnemyBase
		if !collider: return
		
		cause_damage_to_chain(_get_chain(collider))

func cause_damage_to_chain(chain: Array[EnemyBase]) -> void:
	if _chain_invencible: return
	
	for collider in chain:
		var health_component: HealthComponent = collider.get_node_or_null("HealthComponent") as HealthComponent
		if health_component: 
			health_component.take_damage(damage)
			damage_rate_timer.start()
			_chain_invencible = true

func _find_nearest_enemy(enemy: EnemyBase, radius: float) -> EnemyBase:
	var circle := CircleShape2D.new()
	circle.radius = radius
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = false
	query.shape = circle
	
	var overlapping_bodies: Array[Node2D] = get_world_2d().direct_space_state.intersect_shape(query).reduce(func(accum: Array[Node2D], coll: Dictionary) -> Array[Node2D]: return accum + coll.collider)
	
	var enemies: Array[EnemyBase] = overlapping_bodies.filter(func(body: Node2D) -> bool: return body is EnemyBase && body != enemy)
	if enemies.is_empty(): return null
	
	return enemies.reduce(
		func(nearest: EnemyBase, compared_enemy: EnemyBase) -> EnemyBase:
			var nearest_dist: float = enemy.global_position.distance_squared_to(nearest.global_position)
			var current_dist: float = enemy.global_position.distance_squared_to(compared_enemy.global_position)
			return nearest if nearest_dist < current_dist else compared_enemy
	)

func _get_chain(enemy: EnemyBase, radius_reduce_factor: float = 0.5) -> Array[EnemyBase]:
	var ret: Array[EnemyBase] = []
	
	var enemy_search_radius: float = 80.0
	var nearest_enemy: EnemyBase = _find_nearest_enemy(enemy, enemy_search_radius)
	
	if !nearest_enemy: return ret
	ret.append(nearest_enemy)
	
	for enemy_index in range(1, laser_bounce_quantity):
		enemy_search_radius *= radius_reduce_factor
		
		nearest_enemy = _find_nearest_enemy(nearest_enemy, enemy_search_radius)
		
		if !nearest_enemy: return ret
		ret.append(nearest_enemy)
	
	return ret

func _on_damage_rate_timer_timeout() -> void:
	_chain_invencible = false
