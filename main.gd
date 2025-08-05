extends Node2D

var spot_scene = preload("res://weld_spot.tscn")
@onready var spots = $World/Spots

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion \
  and "pressure" in event \
  and not is_zero_approx(event.pressure):
    _weld(event)

func _weld(event: InputEventMouseMotion) -> void:
  var spot_instance = spot_scene.instantiate()
  spot_instance.position = event.position
  spot_instance.pressure = event.pressure
  spot_instance.tilt = event.tilt
  spot_instance.temperature = randf_range(1425.0, 1540.0)
  spots.add_child(spot_instance)
