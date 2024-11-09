shader_type spatial;
render_mode blend_mix, unshaded, cull_back;

group_uniforms Basic_Effects;
uniform float model_height = 3.0;
uniform float dissolve_start : hint_range(0.0, 1.0) = 0.001;
uniform float dissolve_length : hint_range(0.0, 1.0) = 1.0;
uniform float gradient_bias : hint_range(0.1, 5.0) = 1.0;
uniform vec2 noise_direction = vec2(0.0, 1.0);

group_uniforms Noise_Effects;
uniform float noise_speed = 1.0;
uniform float noise_strength = 0.1;
uniform float stretch_factor = 0.6;
uniform sampler2D noise_texture;
// Second noise layer uniforms
uniform sampler2D overlay_noise_texture;
uniform vec2 overlay_noise_direction = vec2(-0.2, 1.0);
uniform float overlay_noise_speed = 1.5;
uniform float overlay_noise_strength = 0.3;
uniform float overlay_stretch_factor = 0.8;

varying float vert_height;
varying vec2 v_uv;

group_uniforms Misc_Effects;
uniform vec3 _color : source_color;
uniform vec3 overlay_color : source_color = vec3(1.0, 0.6, 0.2); // Color for overlay noise
uniform float power_factor = 1.0;
uniform float alpha_intensity_factor = 2.0;
uniform float base_opacity = 0.6;

group_uniforms Fresnel_Effects;
uniform float fresnel_factor = 1.0;
uniform float fresnel_amplification = 2.0;
uniform float fresnel_power = 2.0;
uniform bool enable_fresnel = true;
uniform float min_fresnel = 0.3;

vec3 neon(float value, vec3 color) {
    float ramp = clamp(value, 0.0, 1.0);
    vec3 output_color = vec3(0.0);
    ramp = ramp * ramp;
    output_color += pow(color, vec3(4.0)) * ramp;
    ramp = ramp * ramp;
    output_color += color * ramp;
    ramp = ramp * ramp;
    output_color += vec3(1.0) * ramp;
    return output_color;
}

float fresnel(float amount, vec3 normal, vec3 view) {
    float fresnel_term = pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
    return mix(min_fresnel, 1.0, fresnel_term);
}

void vertex() {
    vert_height = (VERTEX.y + (model_height / 2.0)) / model_height;
    v_uv = UV;
}

void fragment() {
    // Primary dissolve noise
    float time = TIME * noise_speed;
    vec2 moving_uv = v_uv + noise_direction * time;
    vec2 stretched_uv = vec2(moving_uv.x, moving_uv.y * stretch_factor);
    float noise_value = texture(noise_texture, stretched_uv).r * noise_strength;
    
    // Overlay noise
    float overlay_time = TIME * overlay_noise_speed;
    vec2 overlay_moving_uv = v_uv + overlay_noise_direction * overlay_time;
    vec2 overlay_stretched_uv = vec2(overlay_moving_uv.x, overlay_moving_uv.y * overlay_stretch_factor);
    float overlay_noise = texture(overlay_noise_texture, overlay_stretched_uv).r * overlay_noise_strength;
    
    // Calculate gradient and base alpha
    float gradient_height = vert_height - dissolve_start;
    gradient_height *= 1.0 / dissolve_length;
    gradient_height = clamp(pow(gradient_height, gradient_bias) + noise_value, 0.0, 1.0);
    
    float base_alpha = mix(1.0, 0.0, gradient_height);
    base_alpha = pow(base_alpha, power_factor);
    base_alpha = max(base_alpha, base_opacity);
    
    // Combine base color with overlay noise
    vec3 base_color = neon(pow(base_alpha, power_factor), _color);
    vec3 final_color = mix(base_color, overlay_color, overlay_noise * 0.5);
    
    ALBEDO = final_color;
    ALPHA = pow(base_alpha, alpha_intensity_factor);
    
    if (enable_fresnel) {
        float fresnel_effect = fresnel(fresnel_factor, NORMAL, VIEW);
        fresnel_effect = pow(fresnel_effect * fresnel_amplification, fresnel_power);
        ALPHA = mix(base_opacity, ALPHA * fresnel_effect, 0.7);
        
        // Add overlay noise contribution to alpha
        ALPHA = mix(ALPHA, 1.0, overlay_noise * 0.3);
    }
}