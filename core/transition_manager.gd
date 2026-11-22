# Ad Maiorem Dei Gloriam!
## Autoload: TransitionManager
extends CanvasLayer

func change_scene(scene: String) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($ColorRect.material, "shader_parameter/animation_progress", 1.0, 0.5)
	tween.tween_callback(func() -> void: get_tree().change_scene_to_file(scene))
	tween.tween_callback(func() -> void: $ColorRect.rotation_degrees += 180) 
	tween.tween_property($ColorRect.material, "shader_parameter/animation_progress", 0.0, 0.5)
	
