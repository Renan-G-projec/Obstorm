# Ad Maiorem Dei Gloriam!
@tool
class_name Laser
extends RayCast2D

@export var damage: float = 5
@export var color: Color = Color(0.0, 0.776, 0.82, 1.0): set = _on_color_changed
@export var casting: bool = true: set = _on_casting_changed
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
	
	laser_length = laser_max_length
	$CPUParticles2D.emitting = false
	
	_fade_tween.tween_property(%Line2D, "width", 0, 0.2)

func _fade_in() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
	_fade_tween.tween_property(%Line2D, "width", laser_width, 0.2)

func _physics_process(delta: float) -> void:
	if !is_colliding(): 
		laser_length = laser_max_length
		$CPUParticles2D.emitting = false
	else:
		laser_length = (global_position - get_collision_point()).length()
		$CPUParticles2D.emitting = true
		$CPUParticles2D.direction = get_collision_normal()
		
		cause_damage_to_chain()

func cause_damage_to_chain() -> void:
	if _chain_invencible: return
	
	var collider: Node = get_collider() as Node
	if !collider: return
	
	var health_component: HealthComponent = collider.get_node_or_null("HealthComponent") as HealthComponent
	if health_component: 
		health_component.take_damage(damage)
		damage_rate_timer.start()
		_chain_invencible = true


func _on_damage_rate_timer_timeout() -> void:
	_chain_invencible = false
