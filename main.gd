# Ad Maiorem Dei Gloriam!
class_name Main
extends Node

@onready var score_label: RichTextLabel = %ScoreLabel
@onready var score_format: String = score_label.text

var player_score: float = 0.0:
	set(val):
		if val == player_score: return
		player_score = val
		_display_score(player_score)

func _ready() -> void:
	ScoreSystem.already_played = true
	_connect_all_enemies_signals()
	_display_score(player_score)

func _on_player_died() -> void:
	# Pass to menu when it exists
	if player_score > ScoreSystem.highscore:
		ScoreSystem.highscore = player_score

func _connect_all_enemies_signals() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is EnemyBase: 
			enemy.died.connect(_on_enemy_died.bind(enemy))

func _on_enemy_died(enemy: EnemyBase) -> void:
	player_score += enemy.score_on_death

func _display_score(score: float) -> void:
	score_label.text = score_format % int(score)
