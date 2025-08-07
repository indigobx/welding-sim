extends Node

const MAX_POINTS = 100
#const GLOW_COLORS = {
  #500.0: Color(0.0, 0.0, 0.0, 0.0),
  #550.0: Color(0.349, 0.125, 0.129, 1.0),
  #615.0: Color(0.408, 0.11, 0.169, 1.0),
  #680.0: Color(0.482, 0.106, 0.169, 1.0),
  #750.0: Color(0.533, 0.0, 0.0, 1.0),
  #830.0: Color(0.8, 0.0, 0.0, 1.0),
  #865.0: Color(1.0, 0.0, 0.0, 1.0),
  #925.0: Color(1.0, 0.325, 0.286, 1.0),
  #975.0: Color(1.0, 0.722, 0.255, 1.0),
  #1025.0: Color(1.0, 0.839, 0.408, 1.0),
  #1075.0: Color(0.992, 0.914, 0.063, 1.0),
  #1200.0: Color(0.98, 0.992, 0.824, 1.0),
  #1250.0: Color(1.0, 1.0, 1.0, 1.0)
#}
const GLOW_COLORS = {
  500.0: Color(0.0, 0.0, 0.0),
  600.0: Color(0.3, 0.0, 0.0),
  900.0: Color(1.0, 0.5, 0.0),
  1200.0: Color(2.5, 1.5, 1.0),
  1600.0: Color(3.0, 2.5, 2.0),
  2600.0: Color(4.0, 4.0, 3.5),
  3500.0: Color(4.0, 5.0, 6.0)
}
const TEMPER_COLORS = {
  205.0: Color(0.0, 0.0, 0.0, 0.0),
  213.0: Color(0.82, 0.784, 0.631, 1.0),
  233.0: Color(0.816, 0.729, 0.498, 1.0),
  250.0: Color(0.224, 0.078, 0.078, 1.0),
  260.0: Color(0.643, 0.098, 0.549, 1.0),
  285.0: Color(0.29, 0.204, 0.51, 1.0),
  295.0: Color(0.0, 0.0, 0.533, 1.0),
  308.0: Color(0.176, 0.325, 0.584, 1.0),
  323.0: Color(0.341, 0.494, 0.929, 1.0),
  430.0: Color(0.533, 0.659, 0.624, 1.0)
}
const TINT_COLORS = {
  450:  Color("#fff"),
  600:  Color("#999"),
  900:  Color("#444")
}
# Red — normalized glow strenth
# Green — roughness
# Blue — normal strength
# Alpha — cooling speed °C/sec × mm^2
const MATERIAL_PARAMS = {
  0:     Color(0.0,  0.3, 0.25, 1.5),
  400:   Color(0.0, 0.20, 0.5, 1.3),
  800:   Color(0.45, 0.50, 3.0, 1.1),
  1200:  Color(0.75, 0.65, 2.0, 0.9),
  1600:  Color(0.90, 0.75, 0.70, 0.7),
  2000:  Color(1.0,  0.85, 0.80, 0.5),
  3000:  Color(1.0,  0.2, 0.5, 500.0)
}
var temp_ambient = 20.0  # Celsius
# Градиенты:
var glow: GradientF
var temper: GradientF
var tint: GradientF
var temp_params: GradientF

func _ready():
  glow = GradientF.create(GLOW_COLORS.keys()[0], GLOW_COLORS.keys()[-1], GLOW_COLORS)
  temper = GradientF.create(TEMPER_COLORS.keys()[0], TEMPER_COLORS.keys()[-1], TEMPER_COLORS)
  tint = GradientF.create(TINT_COLORS.keys()[0], TINT_COLORS.keys()[-1], TINT_COLORS)
  temp_params = GradientF.create(MATERIAL_PARAMS.keys()[0], MATERIAL_PARAMS.keys()[-1], MATERIAL_PARAMS)


func humanize_size(bytes: float, decimals: int = 2) -> String:
  const UNITS = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"]
  if bytes <= 0:
      return "0 B"
  var unit_index = floor(log(bytes) / log(1024))
  unit_index = min(unit_index, UNITS.size() - 1)
  var size = bytes / pow(1024, unit_index)
  return "%.*f %s" % [decimals, size, UNITS[unit_index]]

func meminfo() -> String:
  var static_mem = Performance.get_monitor(Performance.MEMORY_STATIC)
  var video_mem = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
  var output: String
  output += "Static: %s\n" % humanize_size(static_mem)
  output += "Video: %s" % humanize_size(video_mem)
  return output
