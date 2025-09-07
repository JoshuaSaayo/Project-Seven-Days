extends Area3D

signal detector_triger

@export var dialogue_key : String = ""

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		emit_signal("detector_triger",dialogue_key)
		await get_tree().create_timer(1.0).timeout
		queue_free()
