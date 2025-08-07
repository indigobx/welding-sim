extends Node2D

var spot_scene = preload("res://weld_spot.tscn")
@onready var spots = $World/Spots
var delay = 0.05

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion \
  and "pressure" in event \
  and not is_zero_approx(event.pressure):
    _weld(event)

func _weld(event: InputEventMouseMotion) -> void:
  if not $Timer.is_stopped():
    return
  var spot_instance = spot_scene.instantiate()
  spot_instance.position = event.position
  spot_instance.pressure = event.pressure
  spot_instance.tilt = event.tilt
  spot_instance.temperature = randf_range(1425.0, 1540.0)
  #spot_instance.temperature = randf_range(3000.0, 4000.0)
  $GPUParticles2D.position = event.position
  $GPUParticles2D.emitting = true
  spots.add_child(spot_instance)
  await get_tree().process_frame
  $Timer.start(delay)
  #$GPUParticles2D.emitting = false

func _process(delta: float) -> void:
  var output = "%4.0f spots" % spots.get_child_count() + \
  "\n%3.2f FPS" % Engine.get_frames_per_second() + \
  "\n%s" % Globals.meminfo()
  $Label.text = output
