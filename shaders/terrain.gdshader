shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform vec3 soil_dark : source_color = vec3(0.16, 0.19, 0.16);
uniform vec3 soil_light : source_color = vec3(0.34, 0.35, 0.28);
uniform float detail_scale = 0.19;
uniform float roughness_value = 0.94;
varying vec3 world_position;
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
               mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}
void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
    vec2 p = world_position.xz * detail_scale;
    float broad = noise2(p * 0.18);
    float medium = noise2(p * 1.7);
    float fine = noise2(p * 9.0);
    float pattern = broad * 0.52 + medium * 0.34 + fine * 0.14;
    ALBEDO = mix(soil_dark, soil_light, smoothstep(0.24, 0.78, pattern));
    ROUGHNESS = roughness_value;
    METALLIC = 0.0;
}
