# Ad Maiorem Dei Gloriam!
## Makes the attached node burneable. This will:
## - Make the sprite a little more saturated
## - Cause the defined DPS hitting the dettermined amount of times

class_name BurningComponent
extends Node

@export var dps: float = 10                     ## Damage that it causes per second (not per hit)
@export var hps: int = 2                        ## How much hits (cycles) it will damage per second

@export var health_component: HealthComponent   ## To cause the damage
@export var sprite: Node2D                      ## To apply the modulate

var is_burning: bool = false

var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	
func apply_burning(time: float) -> void:
	assert(health_component, "Error: No health component to do the damage!")
	assert(sprite, "Error: No sprite attached to cause the burning effect!")
	assert(hps > 0 && dps > 0, "Error: DPS and HPS cannot be negative!")

	if is_burning: return
	is_burning = true
	
	var initial_modulate: Color = sprite.self_modulate
	sprite.self_modulate = Color(2.0, 2.0, 2.0, 1.0)
	
	var damage_time: float = 1 / float(hps)
	var damage_of_hit: float = dps / float(hps)
	var elapsed_time: float = 0.0
	
	while elapsed_time < time:
		# If the next tick got bigger than the ellapsed time, it will do a final damage and end the effect
		# So tick time should be damage time OR time until the end, the one which is smaller.
		var tick_time = minf(damage_time, time - elapsed_time)
		var damage_ratio = tick_time / damage_time
		
		_timer.start(tick_time)
		await _timer.timeout
		
		elapsed_time += tick_time
		
		health_component.take_damage(damage_of_hit * damage_ratio)
		
	is_burning = false
	sprite.self_modulate = initial_modulate
