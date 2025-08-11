extends Node2D
class_name WeldSpot

var _tilt: Vector2 = Vector2.ZERO
var _spot_scale: Vector2 = Vector2.ONE
var tilt_deg: float = 0.0
var direction: float = 0.0
var spot_size: float = 1.0
@export var scale_max: Vector2 = Vector2(0.2, 0.5)
@export var scale_min: Vector2 = Vector2(0.15, 0.35)
var spot_scale: Vector2 = Vector2.ONE:
  get:
    return _spot_scale
  set(value):
    _spot_scale = value
    spot_size = spot_scale.length_squared()
    $Sprite2D.scale = value


@export var tilt: Vector2:
  get:
    return _tilt
  set(value):
    _tilt = value
    tilt_deg = rad_to_deg(value.length())
    direction = value.angle()
@export var pressure: float = 1.0
@export var temperature: float = 1400.0
@export var debug: bool = false
@export var overheat: float = 0.0
var mat: ShaderMaterial = preload("res://weld_spot_material.tres")


func _ready() -> void:
  if not debug:
    $Label.queue_free()
  $Sprite2D.material = mat.duplicate()
  $Sprite2D.rotation = direction + PI/2
  temperature += pressure * 100.0
  _set_size()


func _process(delta: float) -> void:
  if temperature > Globals.temp_ambient:
    var params: Color = Globals.temp_params.sample(temperature)
    var glow_color: Color = Globals.glow.sample(temperature)
    #var glow_color = Color(3.0, 2.0, 1.0)
    var temper_color: Color = Globals.temper.sample(temperature)
    var tint_color: Color = Globals.tint.sample(temperature)
    var glow_power = params.r * 0.5
    var roughness = params.g
    var normal_strength = params.b
    var cooling_speed = params.a
    var oh_value = clampf(1.25 - overheat, 0.33, 1.0)
    var oh_color = tint_color * Color(oh_value, oh_value, oh_value)
    $Sprite2D.modulate = tint_color
    $Sprite2D.material.set_shader_parameter("tint_color", oh_color)
    $Sprite2D.material.set_shader_parameter("glow_color", glow_color)
    $Sprite2D.material.set_shader_parameter("glow_power", glow_power)
    $Sprite2D.material.set_shader_parameter("metallic", 0.25)
    $Sprite2D.material.set_shader_parameter("roughness", roughness)
    $Sprite2D.material.set_shader_parameter("specular_power", 2)
    $Sprite2D.material.set_shader_parameter("normal_strength", normal_strength/4)

    var cooling = 4800 * cooling_speed * delta * spot_size  # magic cooling const here
    temperature -= cooling
    #print("%.0f°C (%.2f)   %.2f power" % [temperature, cooling, glow_power])
    if debug:
      $Label.text = "%4.0f  %.1f  %s" % [temperature, overheat, tilt]
  else:
    process_mode = Node.PROCESS_MODE_DISABLED

func _set_size() -> void:
  $Sprite2D.scale = Vector2(
    remap(tilt_deg, 0.0, 90.0, scale_max.x, scale_min.x),
    remap(tilt_deg, 0.0, 90.0, scale_min.y, scale_max.y)
  )
  $Sprite2D.scale *= remap(pressure, 0.0, 1.0, 0.6, 0.8)  # magic thresholds here
  spot_size = $Sprite2D.scale.length_squared()
  spot_scale = $Sprite2D.scale
