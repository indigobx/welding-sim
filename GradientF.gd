extends Resource
class_name GradientF

@export var low: float = 0.0
@export var high: float = 1.0
var _points: Array = []

static func create(low: float, high: float, points: Dictionary) -> GradientF:
  var g = GradientF.new()
  g.low = low
  g.high = high
  g.set_points(points)
  return g

func set_points(points: Dictionary) -> void:
  _points.clear()
  for key in points.keys():
    var offset = float(key)
    var color = Color(points[key])
    _points.append({ "offset": offset, "color": color })
  _points.sort_custom(_compare_offset)

func _compare_offset(a: Dictionary, b: Dictionary) -> bool:
  return a["offset"] < b["offset"]

func sample(x: float) -> Color:
  if _points.is_empty():
    return Color(1, 1, 1)

  if x <= _points[0]["offset"]:
    return _points[0]["color"]
  if x >= _points[-1]["offset"]:
    return _points[-1]["color"]

  for i in range(_points.size() - 1):
    var a = _points[i]
    var b = _points[i + 1]
    if x >= a["offset"] and x <= b["offset"]:
      var t = (x - a["offset"]) / (b["offset"] - a["offset"])
      return a["color"].lerp(b["color"], t)

  return Color(1, 0, 1)  # error fallback
