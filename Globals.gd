extends Node

const MAX_POINTS = 100
const GLOW_COLORS = {
  500.0: Color(0.0, 0.0, 0.0, 0.0),
  550.0: Color(0.349, 0.125, 0.129, 1.0),
  615.0: Color(0.408, 0.11, 0.169, 1.0),
  680.0: Color(0.482, 0.106, 0.169, 1.0),
  750.0: Color(0.533, 0.0, 0.0, 1.0),
  830.0: Color(0.8, 0.0, 0.0, 1.0),
  865.0: Color(1.0, 0.0, 0.0, 1.0),
  925.0: Color(1.0, 0.325, 0.286, 1.0),
  975.0: Color(1.0, 0.722, 0.255, 1.0),
  1025.0: Color(1.0, 0.839, 0.408, 1.0),
  1075.0: Color(0.992, 0.914, 0.063, 1.0),
  1200.0: Color(0.98, 0.992, 0.824, 1.0),
  1250.0: Color(1.0, 1.0, 1.0, 1.0)
}
const TINT_COLORS = {
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
var cooling = 1000.0  # per 1.0 size per second
var temp_ambient = 20.0  # Celsius
# Градиенты:
var glow
var tint

func _ready():
  glow = GradientF.create(GLOW_COLORS.keys()[0], GLOW_COLORS.keys()[-1], GLOW_COLORS)
  tint = GradientF.create(TINT_COLORS.keys()[0], TINT_COLORS.keys()[-1], TINT_COLORS)
