shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D weld_map_tex : hint_default_black;
uniform vec2  weld_map_size = vec2(1024.0);
uniform float temp_min = 0.0;
uniform float temp_max = 2000.0;
uniform float visible_cutoff = 80.0;
uniform float emissive_strength = 2.2;
uniform bool  use_halo = true;
uniform float halo_strength = 1.0;
uniform int   halo_samples = 8;

// Новые:
uniform bool  force_opaque = true;   // <-- СДЕЛАЙ true, чтобы убедиться, что не прозрачный
uniform float min_spot_px = 3.0;     // минимальный радиус, если G=0

vec3 lerp(vec3 a, vec3 b, float t){ return a + (b-a)*clamp(t,0.0,1.0); }
vec3 temp_to_color(float c){
    if (c < 150.0)  return vec3(0.62,0.62,0.65);
    if (c < 250.0)  return lerp(vec3(0.62,0.62,0.65), vec3(0.78,0.62,0.18), (c-150.0)/100.0);
    if (c < 350.0)  return lerp(vec3(0.78,0.62,0.18), vec3(0.50,0.28,0.10), (c-250.0)/100.0);
    if (c < 450.0)  return lerp(vec3(0.50,0.28,0.10), vec3(0.42,0.20,0.55), (c-350.0)/100.0);
    if (c < 550.0)  return lerp(vec3(0.42,0.20,0.55), vec3(0.20,0.38,0.75), (c-450.0)/100.0);
    if (c < 700.0)  return lerp(vec3(0.20,0.38,0.75), vec3(0.55,0.55,0.58), (c-550.0)/150.0);
    if (c < 900.0)  return lerp(vec3(0.55,0.55,0.58), vec3(0.60,0.05,0.02), (c-700.0)/200.0);
    if (c < 1200.0) return lerp(vec3(0.60,0.05,0.02), vec3(0.95,0.42,0.05), (c-900.0)/300.0);
    if (c < 1600.0) return lerp(vec3(0.95,0.42,0.05), vec3(1.00,0.86,0.40), (c-1200.0)/400.0);
    return vec3(1.0);
}

void fragment(){
    vec2 uv = UV;
    vec4 wm = texture(weld_map_tex, uv);
    float tempC = wm.r;
    float size_px = max(wm.g, 0.0);

    float vis = smoothstep(visible_cutoff - 20.0, visible_cutoff + 20.0, tempC);
    vec3 base_col = temp_to_color(clamp(tempC, temp_min, temp_max));
    float t01 = clamp((tempC - temp_min) / max(temp_max - temp_min, 1.0), 0.0, 1.0);
    float heat = pow(t01, 1.2);
    vec3 emissive = base_col * emissive_strength * heat;

    // ореол: всегда есть минимум радиуса, чтоб «точка» была видна
    float halo = 0.0;
    if (use_halo){
        vec2 texel = 1.0 / max(weld_map_size, vec2(1.0));
        float r = max(size_px, min_spot_px);
        int N = clamp(halo_samples, 0, 16);
        for (int i=0; i<16; i++){
            if (i>=N) break;
            float ang = (6.2831853/float(N))*float(i);
            vec2 dir = vec2(cos(ang), sin(ang));
            float s1 = texture(weld_map_tex, uv + dir * texel * r).r;
            float s2 = texture(weld_map_tex, uv + dir * texel * (0.5*r)).r;
            halo += max(s1,0.0) + 0.6*max(s2,0.0);
        }
        if (N>0) halo /= float(N)*1.6;
    }

    vec3 col = base_col + emissive * 0.6 + halo_strength * halo * vec3(1.0, 0.5, 0.2);
    float alpha = force_opaque ? 1.0 : vis; // <-- ОТКЛЮЧАЕМ ПРОЗРАЧНОСТЬ

    COLOR = vec4(col, alpha);
}
