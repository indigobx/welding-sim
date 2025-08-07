shader_type canvas_item;
render_mode blend_premul_alpha; // Для корректного смешивания прозрачности

uniform sampler2D normal_map : hint_normal;
uniform vec4 glow_color : source_color;
uniform float glow_power : hint_range(0.0, 10.0) = 1.0;
uniform float normal_strength : hint_range(0.0, 5.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float specular_power : hint_range(1.0, 128.0) = 32.0;
uniform vec3 reflection_color : source_color = vec3(0.5); // Серый по умолчанию

void fragment() {
    // Базовый цвет из текстуры (без размытия)
    vec4 base_color = texture(TEXTURE, UV);
    
    // Нормали из карты нормалей
    vec3 nmap = texture(normal_map, UV).rgb;
    vec3 normal = normalize((nmap * 2.0 - 1.0) * vec3(normal_strength, normal_strength, 1.0));
    NORMAL = normal;

    // PBR Lighting
    vec3 light_dir = normalize(vec3(1.0, 1.0, 0.5)); // Фиксированное направление света
    vec3 view_dir = vec3(0.0, 0.0, 1.0); // Направление "в камеру"
    vec3 half_dir = normalize(light_dir + view_dir);
    
    // Углы между нормалями и направлениями
    float NdotL = max(dot(normal, light_dir), 0.0);
    float NdotV = max(dot(normal, view_dir), 0.0001);
    float NdotH = max(dot(normal, half_dir), 0.0001);
    
    // Модель GGX (Trowbridge-Reitz) для микроповерхностей
    float alpha = roughness * roughness;
    float alpha_sq = alpha * alpha;
    float denom = (NdotH * NdotH) * (alpha_sq - 1.0) + 1.0;
    float D = alpha_sq / (PI * denom * denom);
    
    // Френелевское отражение (Schlick)
    //vec3 f0 = mix(vec3(0.04), base_color.rgb, metallic);
    vec3 f0 = mix(reflection_color, base_color.rgb, metallic);
    float fresnel = pow(1.0 - NdotV, 5.0);
    vec3 F = f0 + (1.0 - f0) * fresnel;
    
    // Итоговый блик
    vec3 specular = (D * F) * metallic;
    
    // Рассеянный свет (Lambert)
    vec3 diffuse = base_color.rgb * (1.0 - metallic) * NdotL;
    
    // Комбинируем всё + свечение
    vec3 final_color = diffuse + specular + glow_color.rgb * glow_power;
    
    // Финальный цвет с premultiplied alpha
    COLOR = vec4(final_color * base_color.a, base_color.a);
}