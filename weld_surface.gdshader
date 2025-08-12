shader_type canvas_item;

uniform sampler2D points_tex;
uniform int points_count = 0;
uniform vec2 canvas_size = vec2(2048.0, 2048.0);

uniform int k_tail = 96;
uniform float iso_lo = 0.35;
uniform float iso_hi = 0.55;
uniform float normal_scale = 3.0;
uniform float emission_strength = 1.5;

uniform bool use_under_texture = false;
uniform bool debug_view = false;

float metaball(vec2 p, vec2 c_uv, float r_px) {
  float r_uv = r_px / canvas_size.x; // предполагаем квадратные пиксели
  vec2 d = p - c_uv;

  // Небольшая анизотропия по экранным производным
  vec2 dx = dFdx(p);
  vec2 dy = dFdy(p);
  vec2 dir = normalize(dx + dy + vec2(1e-4));
  vec2 nrm = vec2(-dir.y, dir.x);

  float stretch_dir = 1.0;
  float stretch_nrm = 0.7;

  float q = dot(d, dir) / (r_uv * stretch_dir);
  float s = dot(d, nrm) / (r_uv * stretch_nrm);

  float dist2 = q*q + s*s;
  return exp(-dist2);
}

void fragment() {
  // UV этого CanvasItem (TextureRect): 0..1 по его собственному размеру
  vec2 uv = UV;

  float field = 0.0;
  float heat_acc = 0.0;

  int n = min(points_count, k_tail);
  ivec2 tex_sz = textureSize(points_tex, 0);

  for (int i = 0; i < n; i++) {
    int idx = (points_count - 1 - i);
    idx = int(mod(float(idx), float(tex_sz.x)));
    vec4 p = texelFetch(points_tex, ivec2(idx, 0), 0);
    vec2 c_uv = p.xy;
    float r_px = p.z;
    float heat = p.w;

    float f = metaball(uv, c_uv, r_px);
    field += f;
    heat_acc += f * heat;
  }

  float mask = smoothstep(iso_lo, iso_hi, field);

  // Режим отладки: смотрим на поле напрямую
  if (debug_view) {
    COLOR = vec4(vec3(field), 1.0);
  }

  // Градиент для «псевдо-нормали» (Light2D)
  float field_dx = dFdx(field);
  float field_dy = dFdy(field);
  vec3 nrm = normalize(vec3(-field_dx * normal_scale, -field_dy * normal_scale, 1.0));

  vec3 base_col = mix(vec3(0.55, 0.58, 0.62), vec3(0.45, 0.47, 0.52), clamp(field, 0.0, 1.0));
  float heat_norm = (n > 0) ? heat_acc / float(n) : 0.0;
  vec3 emission = mix(vec3(0.0), vec3(1.0, 0.6, 0.2), clamp(heat_norm, 0.0, 1.0)) * emission_strength;

  vec3 under_rgb = use_under_texture ? texture(TEXTURE, UV).rgb : vec3(0.0);

  COLOR.rgb = mix(under_rgb, base_col, mask) + emission * mask * 0.6;
  COLOR.a = mask;

  NORMAL = vec3(nrm.xy, 1.0);
}
