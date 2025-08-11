extends Node2D

var spot_scene = preload("res://weld_spot.tscn")
@onready var spots = $World/Spots
var delay = 0.05
var last_event := InputEventMouseMotion.new()
var welding: bool = false
@onready var vp_size = get_viewport().get_visible_rect().size
var weld_map: Image
var tex: ImageTexture

func _ready() -> void:
  #pass
  weld_map = Image.create(vp_size.x, vp_size.y, false, Image.FORMAT_RGBF)
  weld_map.fill(Color(0.0, 0.0, 0.0))
  var weld_map_size = weld_map.get_size()
  tex = ImageTexture.create_from_image(weld_map)
  $TextureRect.texture = tex
  $TextureRect.material.set_shader_parameter("weld_map_tex", tex)
  $TextureRect.material.set_shader_parameter("weld_map_size", weld_map_size)
  $TextureRect.size = vp_size
  $TextureRect.position = Vector2.ZERO

func _process(delta: float) -> void:
  _update_spots()
  if Engine.get_frames_drawn() % 60 == 0:
    $TextureRect.texture.update(weld_map)

  var output = "%4.0f spots" % spots.get_child_count() + \
  "\n%3.2f FPS" % Engine.get_frames_per_second() + \
  "\n%s" % Globals.meminfo() + \
  "\n%.3f" % last_event.pressure
  $Label.text = output

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion \
  and "pressure" in event \
  and not is_zero_approx(event.pressure):
    last_event = event
    if welding:
      _try_weld(event)
    else:
      _try_strike_arc(event)
  else:
    last_event = InputEventMouseMotion.new()

func _update_spots() -> void:
  weld_map.fill(Color(0.0, 0.0, 0.0))
  for spot in spots.get_children():
    var color = Color(spot.temperature, spot.spot_size, 0.0)
    weld_map.set_pixel(
      spot.position.x,
      spot.position.y,
      color
    )
  

func _put_temperature(where: Vector2, value: float) -> void:
  var px = weld_map.get_pixel(where.x, where.y)
  weld_map.set_pixel(
    where.x,
    where.y,
    Color(value, px.g, px.b)
  )
  tex.update(weld_map)

func _put_spot(where, pressure) -> void:
  var px = weld_map.get_pixel(where.x, where.y)
  weld_map.set_pixel(
    where.x,
    where.y,
    Color(px.r, pressure*20, px.b)
  )
  tex.update(weld_map)

func _try_strike_arc(event: InputEventMouseMotion) -> void:
  if event.pressure < 0.5:
    _weld(event)
  else:
    _fail_arc(event)

func _fail_arc(event: InputEventMouseMotion) -> void:
  $GPUParticles2D.position = event.position
  $GPUParticles2D.emitting = true
  await get_tree().process_frame
  welding = false

func _try_weld(event: InputEventMouseMotion) -> void:
  if event.pressure < 0.35:
    _weld(event)
  if event.pressure >= 0.6:
    _burn(event)
  if event.pressure >= 0.35:
    _burn(event)

func _burn(event: InputEventMouseMotion) -> void:
  var last_spot = spots.get_children()[-1]
  last_spot.temperature += randf_range(10.0, 25.0)
  last_spot.overheat += 0.01
  last_spot.spot_scale += Vector2(0.001, 0.001) * last_spot.tilt.normalized()
  
  var px = weld_map.get_pixel(last_spot.position.x, last_spot.position.y)
  var color = Color(last_spot.temperature, px.g, px.b)
  _put_temperature(last_spot.position, last_spot.temperature)

func _do_slag(event: InputEventMouseMotion) -> void:
  if not $Timer.is_stopped():
    return
  welding = true
  var spot_instance = spot_scene.instantiate()
  var rand_offset = Vector2(
    randf_range(-event.tilt.x, event.tilt.x),
    randf_range(-event.tilt.y, event.tilt.y)
  ) + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
  spot_instance.position = event.position + rand_offset*5
  spot_instance.pressure = event.pressure
  spot_instance.tilt = event.tilt
  spot_instance.temperature = randf_range(925.0, 1040.0)
  spot_instance.overheat = event.pressure
  spot_instance.scale_min = Vector2(0.05, 0.2)
  spot_instance.scale_max = Vector2(0.3, 0.6)
  #spot_instance.debug = true
  $GPUParticles2D.position = event.position
  $GPUParticles2D.emitting = true
  spots.add_child(spot_instance)
  
  _put_temperature(spot_instance.position, spot_instance.temperature)
  _put_spot(spot_instance.position, spot_instance.spot_size)
  await get_tree().process_frame
  $Timer.start(delay)

func _weld(event: InputEventMouseMotion) -> void:
  if not $Timer.is_stopped():
    return
  welding = true
  var spot_instance = spot_scene.instantiate()
  spot_instance.position = event.position
  spot_instance.pressure = event.pressure
  spot_instance.tilt = event.tilt
  spot_instance.temperature = randf_range(1425.0, 1540.0)
  $GPUParticles2D.position = event.position
  $GPUParticles2D.emitting = true
  spots.add_child(spot_instance)
  _put_temperature(spot_instance.position, spot_instance.temperature)
  _put_spot(spot_instance.position, spot_instance.spot_size)
  await get_tree().process_frame
  $Timer.start(delay)
  #$GPUParticles2D.emitting = false
