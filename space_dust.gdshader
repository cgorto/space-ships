shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform vec3 camera_position;
uniform float extent = 500.0;

void vertex() {
    // Wrap particles around camera
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 relative_pos = world_pos - camera_position;
    float size = extent * 2.0;
    
    // Wrap on all axes
    if(relative_pos.x > extent) relative_pos.x -= size;
    if(relative_pos.x < -extent) relative_pos.x += size;
    if(relative_pos.y > extent) relative_pos.y -= size;
    if(relative_pos.y < -extent) relative_pos.y += size;
    if(relative_pos.z > extent) relative_pos.z -= size;
    if(relative_pos.z < -extent) relative_pos.z += size;
    
    // Apply wrapped position
    vec3 wrapped_pos = camera_position + relative_pos;
    VERTEX = (inverse(MODEL_MATRIX) * vec4(wrapped_pos, 1.0)).xyz;
    
    // Distance-based fade
    float distance = length(relative_pos);
    float fade = 1.0 - smoothstep(extent * 0.5, extent, distance);
    COLOR.a *= fade;
}

void fragment() {
    // Create a soft particle look
    float soft_edge = smoothstep(0.5, 0.0, length(UV - vec2(0.5)));
    ALBEDO = COLOR.rgb;
    ALPHA = COLOR.a * soft_edge;
}