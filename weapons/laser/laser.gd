# Ad Maiorem Dei Gloriam!
@tool
class_name Laser
extends RayCast2D

@export var color: Color = Color(0.0, 0.776, 0.82, 1.0): set = _on_color_changed
@export var casting: bool = true: set = _on_casting_changed
@export var laser_max_length: float = 160
@export var laser_length: float = laser_max_length: set = _on_laser_length_changed
@export var laser_width: float = 2.0

var _fade_tween: Tween

func _on_color_changed(new_color: Color) -> void:
	color = new_color
	modulate = new_color

func _on_casting_changed(new_casting: bool) -> void:
	if new_casting == casting: return
	
	casting = new_casting
	if casting:
		_fade_in()
	else:
		_fade_out()

func _on_laser_length_changed(new_length: float) -> void:
	if (new_length == laser_length): return
	
	laser_length = new_length
	target_position.x = new_length
	$CPUParticles2D.position.x = new_length
	%Line2D.set_point_position(1, Vector2(new_length, 0))

func _fade_out() -> void:
	if _fade_tween && _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	
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
