extends Node2D
class_name WeldSDF2D

const MAX_POINTS := 2048
const TEX_W := MAX_POINTS
const TEX_H := 1

@export var base_radius_px: float = 10.0
@export var speed_stretch: float = 0.6
@export var tilt_anisotropy: float = 0.7

var points_img: Image
var points_tex: ImageTexture

var head: int = 0
var count: int = 0
var dirty: bool = false

@onready var target: TextureRect = $World/TextureRect

func _ready() -> void:
  points_img = Image.create(TEX_W, TEX_H, false, Image.FORMAT_RGBAF)
  points_img.fill(Color(0, 0, 0, 0))
  points_tex = ImageTexture.create_from_image(points_img)

  var mat: ShaderMaterial = target.material as ShaderMaterial
  if mat == null:
    push_error("World/TextureRect.material должен быть ShaderMaterial")
    return

  # Передаём параметры в шейдер
  mat.set_shader_parameter("points_tex", points_tex)
  mat.set_shader_parameter("points_count", 0)
  mat.set_shader_parameter("canvas_size", target.size) # size самого TextureRect
  mat.set_shader_parameter("use_under_texture", false) # чтобы не зависеть от базовой текстуры
  mat.set_shader_parameter("debug_view", false) # можно включить для проверки

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    var mm: InputEventMouseMotion = event

    # Координаты **внутри TextureRect**
    var local_pos: Vector2 = target.get_local_mouse_position()
    if local_pos.x < 0.0 or local_pos.y < 0.0 or local_pos.x > target.size.x or local_pos.y > target.size.y:
      return

    var vel: Vector2 = mm.velocity
    var speed: float = vel.length()

    var p: float = clamp(mm.pressure, 0.0, 1.0)
    var radius: float = lerp(base_radius_px * 0.5, base_radius_px * 1.75, p)

    var stretch: float = clamp(speed / 1200.0, 0.0, 1.0) * speed_stretch
    var tvec: Vector2 = mm.tilt
    var tilt_len: float = clamp(tvec.length(), 0.0, 1.0)
    var anis: float = 1.0 + tilt_len * tilt_anisotropy

    var heat: float = clamp(p * (1.0 - stretch * 0.7), 0.0, 1.0)

    var place_point: bool = true
    if count > 0:
      var prev_idx: int = (head - 1 + MAX_POINTS) % MAX_POINTS
      var prev_uvr: Vector4 = _get_point(prev_idx)
      var prev_local: Vector2 = Vector2(prev_uvr.x, prev_uvr.y) * target.size
      var dist: float = local_pos.distance_to(prev_local)
      var min_step: float = radius * 0.5
      place_point = dist >= min_step

    if place_point:
      _push_point(local_pos, radius, heat)
      dirty = true

func _process(_dt: float) -> void:
  if dirty:
    points_tex.update(points_img)
    dirty = false

  var mat: ShaderMaterial = target.material as ShaderMaterial
  if mat:
    mat.set_shader_parameter("points_count", count)
    mat.set_shader_parameter("canvas_size", target.size)

func _push_point(local_px: Vector2, radius_px: float, heat: float) -> void:
  # Нормируем в UV [0..1] относительно **TextureRect**
  var uv: Vector2 = local_px / target.size
  uv.x = clamp(uv.x, 0.0, 1.0)
  uv.y = clamp(uv.y, 0.0, 1.0)

  var idx: int = head
  points_img.set_pixel(idx, 0, Color(uv.x, uv.y, radius_px, heat))

  head = (head + 1) % MAX_POINTS
  count = min(count + 1, MAX_POINTS)


func _get_point(i: int) -> Vector4:
  var c: Color = points_img.get_pixel(i, 0)
  return Vector4(c.r, c.g, c.b, c.a)
