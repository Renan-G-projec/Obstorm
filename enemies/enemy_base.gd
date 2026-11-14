# Ad Maiorem Dei Gloriam!
class_name EnemyBase
extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 40.0

var _following: bool = true

func _ready() -> void:
	var target_position_update_timer: Timer = Timer.new()
	target_position_update_timer.autostart = true
	target_position_update_timer.wait_time = 0.3
	target_position_update_timer.timeout.connect(func() -> void: %NavigationAgent2D.target_position = target.global_position)
	add_child(target_position_update_timer)
	
	if %Area2D.get_overlapping_bodies().any(func(val: Node2D) -> bool: return val is Player):
		_following = false

func _physics_process(delta: float) -> void:
	if !_following: return
	if %NavigationAgent2D.is_navigation_finished() || !%NavigationAgent2D.is_target_reachable(): return
	
	var next_position: Vector2 = %NavigationAgent2D.get_next_path_position()
	
	var dir: Vector2 = global_position.direction_to(next_position)
	rotation = global_position.direction_to(target.global_position).angle()
	
	velocity = dir * speed;
	move_and_slide()


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
	queue_free()
