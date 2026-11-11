class_name FloatingDamage
extends Label

func setup(amount: int, is_critical: bool = false) -> void:
	text = str(amount)
	z_index = 100
	
	if is_critical:
		modulate = Color(1.0, 0.2, 0.2)
		scale = Vector2(1.3, 1.3)
	else:
		modulate = Color(1.0, 0.9, 0.3)
		scale = Vector2(1.0, 1.0)
	
	var tween = create_tween().set_parallel(true)
	var target_pos = position + Vector2(randf_range(-15, 15), -35)
	
	tween.tween_property(self, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
