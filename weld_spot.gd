extends Node2D
class_name WeldSpot

var spot_size: Vector2
var _tilt: Vector2 = Vector2.ZERO
var tilt_deg: float = 0.0
var direction: float = 0.0

var scale_max: Vector2 = Vector2(0.2, 0.5)
var scale_min: Vector2 = Vector2(0.15, 0.35)

@export var tilt: Vector2:
  get:
    return _tilt
  set(value):
    _tilt = value
    tilt_deg = rad_to_deg(value.length())
    direction = value.angle()
@export var pressure: float = 1.0
@export var temperature: float = 1400.0
var cool_temp: float = 20.0  # 20.0°C
var cooling: float = 1000.0  # per 1.0 size per second


func _ready() -> void:
  rotation = direction + PI/2
  _set_size()

func _process(delta: float) -> void:
  if temperature > cool_temp:
    _cooldown(delta)
    var glow = Globals.glow.sample(temperature)
    $Sprite2D.modulate = Color.WHITE + glow
    $PointLight2D.color = Color.WHITE + glow
    $PointLight2D.energy = (glow.r + glow.g + glow.b) * glow.a
  else:
    process_mode = Node.PROCESS_MODE_DISABLED

func _set_size() -> void:
  scale = Vector2(
    remap(tilt_deg, 0.0, 90.0, scale_max.x, scale_min.x),
    remap(tilt_deg, 0.0, 90.0, scale_min.y, scale_max.y)
  )
  scale *= remap(pressure, 0.0, 1.0, 0.6, 0.8)


func _cooldown(delta) -> void:
  temperature -= cooling * scale.length_squared() * 2 * delta
