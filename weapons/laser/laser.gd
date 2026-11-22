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

var _chain_invencible: bool = false
var _fade_tween: Tween
var _was_hitting_enemy: bool = false # Control flag to optimize line2d syncs

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
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
	$CPUParticles2D.emitting = false
	
	var collider: EnemyBase = get_collider() as EnemyBase
	if collider:
		_sync_line_with_chain(collider.get_chain(80, 0.5, 3))
		
	await _fade_tween.tween_property(%Line2D, "width", 0, 0.2).finished
	laser_length = laser_max_length

func _fade_in() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
	var collider: EnemyBase = get_collider() as EnemyBase
	if collider:
		_sync_line_with_chain(collider.get_chain(80, 0.5, 3))
	await _fade_tween.tween_property(%Line2D, "width", laser_width, 0.2).finished
	

func _physics_process(delta: float) -> void:
	if _was_hitting_enemy:
		_was_hitting_enemy = false
		
		%Line2D.clear_points()
		%Line2D.add_point(Vector2.ZERO)
		%Line2D.add_point(target_position.normalized() * laser_length)
	
	if !is_colliding(): 
		laser_length = laser_max_length
		$CPUParticles2D.emitting = false
	else:
		laser_length = (global_position - get_collision_point()).length()
		$CPUParticles2D.emitting = true
		$CPUParticles2D.direction = get_collision_normal()
		
		var collider: EnemyBase = get_collider() as EnemyBase
		if !collider: return
		
		
		var chain: Array[EnemyBase] = collider.get_chain(80.0, 0.5, 3)
		_cause_damage_to_chain(chain)
		_sync_line_with_chain(chain)
		
		_was_hitting_enemy = true

func _cause_damage_to_chain(chain: Array[EnemyBase], damage_reducer: float = 0.25) -> void:
	if _chain_invencible: return
	_chain_invencible = true
	damage_rate_timer.start()
	
	var damage_to_cause: float = damage
	for collider in chain:
		var health_component: HealthComponent = collider.get_node_or_null("HealthComponent") as HealthComponent
		if health_component: 
			health_component.take_damage(damage_to_cause)
			damage_to_cause *= damage_reducer

func _sync_line_with_chain(chain: Array[EnemyBase]) -> void:
	%Line2D.clear_points()
	%Line2D.add_point(Vector2.ZERO)
	
	for enemy: EnemyBase in chain:
		%Line2D.add_point(to_local(enemy.global_position))

func _on_damage_rate_timer_timeout() -> void:
	_chain_invencible = false
