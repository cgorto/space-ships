shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, skip_vertex_transform;

// Physics interpolation data

uniform float engine_delta;

// Instance custom data will store:
// r: previous position x
// g: previous position y
// b: previous position z
instance uniform vec4 instance_custom;


void vertex() {
    // Simplified version - just offset in world space
    vec3 velocity = instance_custom.xyz;
    VERTEX += velocity * engine_delta;
}
