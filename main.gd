# Ad Maiorem Dei Gloriam!
class_name Main
extends CanvasLayer

@onready var score_label: RichTextLabel = %ScoreLabel
@onready var score_format: String = score_label.text

var screenshake_defined_time: float = 1.0
var screenshake_time_remaining: float = 0.0
var screenshake_intensity: float = 10.0

var player_score: float = 0.0:
	set(val):
		if val == player_score: return
		player_score = val
		_display_score(player_score)

func _ready() -> void:
	ScoreSystem.already_played = true
	_connect_all_enemies_signals()
	_display_score(player_score)

func _physics_process(delta: float) -> void:
	if screenshake_time_remaining > 0:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * screenshake_intensity * (screenshake_time_remaining / screenshake_defined_time)
		screenshake_time_remaining -= delta
	else:
		offset = Vector2.ZERO

func _on_player_died() -> void:
	# Pass to menu when it exists
	if player_score > ScoreSystem.highscore:
		ScoreSystem.highscore = player_score

func _screenshake(intensity: float = 10.0, time: float = 0.4) -> void:
	if time != 0:
		screenshake_defined_time = time
	screenshake_time_remaining = time
	screenshake_intensity = intensity

func _connect_all_enemies_signals() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is EnemyBase: 
			enemy.died.connect(_on_enemy_died.bind(enemy))

func _on_enemy_died(enemy: EnemyBase) -> void:
	player_score += enemy.score_on_death
	if Preferences.screenshake_enabled:
		_screenshake(5, 0.2)

func _display_score(score: float) -> void:
	score_label.text = score_format % int(score)
