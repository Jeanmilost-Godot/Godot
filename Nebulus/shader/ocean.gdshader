shader_type spatial;
render_mode depth_draw_always;

// --- Uniforms ---
group_uniforms Matrices;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

group_uniforms Wave_Settings;
uniform float wave_strength : hint_range(0.0, 2.0, 0.05) = 1.0;

group_uniforms Material_PBR;
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0) = 0.5;

group_uniforms Color_Settings;
uniform vec3 water_color : source_color = vec3(0.01, 0.05, 0.07);
uniform vec3 deep_water_color : source_color = vec3(0.0, 0.01, 0.02);
uniform vec3 water_absorption : source_color = vec3(0.3, 0.06, 0.02);
uniform float max_depth : hint_range(0.1, 50.0, 0.1) = 15.0;
uniform float fade_start_depth : hint_range(0.0, 50.0, 0.1) = 0.5;

group_uniforms Refraction;
uniform float refraction_strength : hint_range(0.0, 2.0, 0.01) = 0.5;
uniform float refraction_distance_fade : hint_range(0.0, 100.0, 1.0) = 10.0;

group_uniforms Caustics;
uniform sampler2D caustics_texture : filter_linear_mipmap, repeat_enable;
uniform float caustics_scale : hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float caustics_speed : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float caustics_intensity : hint_range(0.0, 2.0, 0.1) = 0.8;
uniform float caustics_depth_fade : hint_range(0.0, 1.0, 0.01) = 0.7;

group_uniforms Foam;
uniform vec3 foam_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 foam_edge_color : source_color = vec3(0.005, 0.01, 0.03);
uniform float foam_depth_start : hint_range(0.0, 5.0, 0.01) = 0.8;
uniform float foam_depth_end   : hint_range(0.0, 5.0, 0.01) = 0.0;
uniform float foam_noise_scale : hint_range(0.0, 10.0, 0.01) = 2.0;
uniform float foam_noise_speed : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float foam_cutoff      : hint_range(0.0, 1.0, 0.01) = 0.7;
uniform float foam_crest_threshold : hint_range(0.0, 1.0, 0.01) = 0.7;
uniform float foam_crest_amount    : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform vec2 foam_edge_offset = vec2(0.02, 0.02);
uniform float voronoi_scale   : hint_range(0.0, 50.0) = 9.0;
uniform float voronoi_strength : hint_range(0.0, 8.0) = 0.8;

// --- Varyings ---
varying vec3 world_vert;
varying float wave_height;
varying vec3 vertex_normal_world;

// --- Helper Functions ---

/**
* Generates a pseudo-random float from a vec2 coordinate.
*@param p - The input 2D position vector.
*@return A random float value between 0.0 and 1.0.
*/
float hash12(vec2 p) {
    uvec2 q = uvec2(ivec2(p)) * uvec2(1597334677u, 3812015801u);
    uint n = (q.x ^ q.y) * 1597334677u;
    return float(n) * (1.0 / 4294967295.0);
}

/**
* Generates a pseudo-random float from a vec3 coordinate.
*@param p - The input 3D position vector.
*@return A random float value between 0.0 and 1.0.
*/
float hash13(vec3 p) {
    uvec3 q = uvec3(ivec3(p)) * uvec3(1597334677u, 3812015801u, 2798796415u);
    uint n = (q.x ^ q.y ^ q.z) * 1597334677u;
    return float(n) * (1.0 / 4294967295.0);
}

/**
* Generates a pseudo-random vec2 coordinate vector from a vec2 seed.
*@param p - The input 2D position vector seed.
*@return A random vec2 coordinate pair.
*/
vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

/**
* Computes 2D Voronoi noise pattern using cell distance metrics.
*@param uv - The texturing coordinates to sample noise over.
*@return The nearest distance value determining cell boundaries.
*/
float voronoi(vec2 uv) {
    vec2 n = floor(uv);
    vec2 f = fract(uv);
    float m_dist = 1.0;
    for (int j = -1; j <= 1; ++j) {
        for (int i = -1; i <= 1; ++i) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = hash22(n + g);
            o = 0.5 + 0.5 * sin(TIME * foam_noise_speed + 6.2831 * o);
            vec2 r = g - f + o;
            float d = dot(r, r);
            m_dist = min(m_dist, d);
        }
    }
    return m_dist;
}

/**
* Computes a smooth value noise gradient map in 2D space.
*@param p - The input coordinate position.
*@return A signed fractional noise float range between -1.0 and 1.0.
*/
float noise(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return -1.0 + 2.0 * mix(mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
                            mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x), u.y);
}

/**
* Computes standard smooth value noise across 3D coordinates.
*@param p - The input 3D coordinate vector.
*@return An interpolated random float value between 0.0 and 1.0.
*/
float noise3d(in vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(
            mix(hash13(i + vec3(0.0, 0.0, 0.0)), hash13(i + vec3(1.0, 0.0, 0.0)), f.x),
            mix(hash13(i + vec3(0.0, 1.0, 0.0)), hash13(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
        mix(
            mix(hash13(i + vec3(0.0, 0.0, 1.0)), hash13(i + vec3(1.0, 0.0, 1.0)), f.x),
            mix(hash13(i + vec3(0.0, 1.0, 1.0)), hash13(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

/**
* Fractal Brownian Motion built using layers of sharpened Voronoi structures.
*@param uv - The structural tracking coordinates.
*@return A cumulative multi-octave sharp foam mask float intensity value.
*/
float fbm_voronoi(vec2 uv) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < 3; i++) {
        float val = 1.0 - voronoi(uv);
        val = pow(val, 2.0);
        v += a * val;
        uv = rot * uv * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

/**
* Evaluates the wave height displacement at a given coordinate position using the IE_ST_Water equation.
*@param pos_xz - The horizontal X and Z components of the vertex position.
*@param time - The dynamic global system time clock parameter.
*@return The calculated scalar height displacement offset value.
*/
float get_wave_height(vec2 pos_xz, float time) {
    float swell1 = sin(pos_xz.x * 0.15 + time * 0.3) * cos(pos_xz.y * 0.12 + time * 0.25);
    float swell2 = sin(pos_xz.x * 0.18 - pos_xz.y * 0.15 + time * 0.35) * 0.8;

    float wind1 = sin(pos_xz.x * 0.5 + pos_xz.y * 0.4 + time * 0.9) * 0.5;
    float wind2 = sin(pos_xz.x * 0.7 - pos_xz.y * 0.6 + time * 1.1) * 0.4;

    float ripple1 = sin(pos_xz.x * 2.0 + pos_xz.y * 1.8 + time * 1.8) * 0.2;
    float ripple2 = sin(pos_xz.x * 2.8 - pos_xz.y * 2.3 - time * 2.1) * 0.15;

    float chop1 = sin(pos_xz.x * 4.5 + time * 2.8) * 0.1;
    float chop2 = sin(pos_xz.y * 5.2 - time * 3.2) * 0.08;

    return (swell1 * 1.2 + swell2 + wind1 + wind2 + ripple1 + ripple2 + chop1 + chop2) * wave_strength;
}

/**
* Determines depth values transformed into view-space units from a raw hardware depth buffer texture.
*@param d_tex - The active sampler texture referencing the scene depth buffer pass.
*@param uv - Normalized coordinates pinpointing the exact fragment position to query.
*@param inv_proj - Inverse transformation projections converting normalized coordinates to view space.
*@param outputIsSRGB - Boolean state flagging true if active graphics API outputs use SRGB constraints (OpenGL vs Vulkan backend rules).
*@return The calculated view-space distance parameter mapping out depth layers behind the surface.
*/
float get_linear_depth(sampler2D d_tex, vec2 uv, mat4 inv_proj, bool outputIsSRGB) {
    float depth = texture(d_tex, uv).x;
    vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
    if (outputIsSRGB) {
        ndc.z = depth * 2.0 - 1.0;
    }
    vec4 view = inv_proj * vec4(ndc, 1.0);
    return -view.z / view.w;
}

// --- Main Stages ---

void vertex() {
    // Process coordinates using the pre-divided geometry plane
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Evaluate exact height configurations using IE_ST_Water calculations
    wave_height = get_wave_height(world_pos.xz, TIME);
    VERTEX.y += wave_height;
    
    // Recalculate local model positions to pass along correct values to fragment stages
    world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Derive surface analytical normal lines using finite differences
    float offset = 0.08;
    float hL = get_wave_height(world_pos.xz - vec2(offset, 0.0), TIME);
    float hR = get_wave_height(world_pos.xz + vec2(offset, 0.0), TIME);
    float hD = get_wave_height(world_pos.xz - vec2(0.0, offset), TIME);
    float hU = get_wave_height(world_pos.xz + vec2(0.0, offset), TIME);
    
    vec3 tangentX = normalize(vec3(1.0, (hR - hL) / (2.0 * offset), 0.0));
    vec3 tangentZ = normalize(vec3(0.0, (hU - hD) / (2.0 * offset), 1.0));
    vertex_normal_world = normalize(cross(tangentZ, tangentX));
}

void fragment() {
    // Standard normal alignments
    float dist_to_cam = length(VERTEX);
    NORMAL = (VIEW_MATRIX * vec4(vertex_normal_world, 0.0)).xyz;
    
    // Linearization setups tracking structural depth constraints
    float water_linear_depth = -VERTEX.z;
    float bg_linear_depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
    float thickness = max(0.0, bg_linear_depth - water_linear_depth);
    
    // Refraction tracking handling
    vec3 view_vertex_normal = (VIEW_MATRIX * vec4(vertex_normal_world, 0.0)).xyz;
    vec2 normal_offset = NORMAL.xy - view_vertex_normal.xy;
    float ref_dist_factor = clamp(refraction_distance_fade / max(0.1, dist_to_cam), 0.0, 1.0);
    float ref_depth_mask = smoothstep(0.0, max_depth, thickness);
    vec2 refraction_offset = normal_offset * refraction_strength * ref_dist_factor * ref_depth_mask * 0.05;
    
    vec2 distorted_uv = SCREEN_UV + refraction_offset;
    float distorted_bg_depth = get_linear_depth(DEPTH_TEXTURE, distorted_uv, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
    
    // Mitigate potential transparency artifacts along physical boundaries
    if (distorted_bg_depth < water_linear_depth - 0.001) {
        distorted_uv = SCREEN_UV;
        distorted_bg_depth = bg_linear_depth;
    }
    
    vec3 screen_color = texture(SCREEN_TEXTURE, distorted_uv).rgb;
    thickness = max(0.0, distorted_bg_depth - water_linear_depth);
    
    // Render out structural volumetric underwater fog configurations
    float fade_range = max(0.001, max_depth - fade_start_depth);
    float depth_ratio = clamp((thickness - fade_start_depth) / fade_range, 0.0, 1.0);
    
    // Compute Caustics across depth bounds
    vec4 bg_ndc = vec4(distorted_uv * 2.0 - 1.0, texture(DEPTH_TEXTURE, distorted_uv).x, 1.0);
    if (OUTPUT_IS_SRGB) {
        bg_ndc.z = bg_ndc.z * 2.0 - 1.0;
    }
    vec4 bg_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * bg_ndc;
    vec3 bg_world_pos = bg_world.xyz / bg_world.w;
    
    if (thickness > 0.0) {
        vec2 caustics_uv1 = bg_world_pos.xz * caustics_scale;
        caustics_uv1.x += TIME * caustics_speed;
        vec2 caustics_uv2 = bg_world_pos.xz * caustics_scale * 0.7;
        caustics_uv2.y -= TIME * caustics_speed * 0.8;
        float caustics_sample1 = texture(caustics_texture, caustics_uv1).r;
        float caustics_sample2 = texture(caustics_texture, caustics_uv2).r;
        float caustics_value = caustics_sample1 * caustics_sample2;
        float caustics_fade = 1.0 - clamp(thickness * caustics_depth_fade, 0.0, 1.0);
        screen_color += caustics_value * caustics_intensity * caustics_fade;
    }
    
    // Beer-Lambert physical color absorption formulas
    vec3 transmittance = exp(-thickness * water_absorption);
    vec3 water_volume_color = mix(water_color, deep_water_color, depth_ratio);
    vec3 apparent_seabed_color = screen_color * water_volume_color;
    
    // Commit adjustments directly to master albedo channels
    ALBEDO = mix(water_volume_color, apparent_seabed_color, transmittance);
    
    // Foam calculations
    float foam_mask_primary = 0.0;
    float foam_mask_shadow  = 0.0;
    
    float depth_foam_factor = smoothstep(foam_depth_start, foam_depth_end, thickness);
    float wave_crest_factor = smoothstep(foam_crest_threshold, foam_crest_threshold - 0.1, vertex_normal_world.y);
    wave_crest_factor *= foam_crest_amount;
    float foam_level = clamp(depth_foam_factor + wave_crest_factor, 0.0, 1.0);
    
    vec2 flow_uv = world_vert.xz * 0.5 + TIME * 0.05 * foam_noise_speed;
    vec2 warp = vec2(noise(flow_uv), noise(flow_uv + vec2(5.2, 1.3))) * 0.5;
    
    if (distorted_bg_depth > water_linear_depth) {
        vec2 foam_uv = world_vert.xz * foam_noise_scale + warp;
        float emergence_noise = noise3d(vec3(world_vert.xz * 0.5, TIME * 0.2 * foam_noise_speed));
        emergence_noise = smoothstep(0.0, 1.0, emergence_noise * 0.5 + 0.5);
        float effective_emergence = mix(emergence_noise, 1.0, foam_level);
        
        float foam_noise_val = fbm_voronoi(foam_uv) * effective_emergence;
        
        vec2 foam_uv_shadow = (world_vert.xz + foam_edge_offset) * foam_noise_scale + warp;
        float foam_noise_shadow_val = fbm_voronoi(foam_uv_shadow) * effective_emergence;
        
        float combined_noise  = foam_noise_val + foam_level;
        float combined_shadow = foam_noise_shadow_val + foam_level;
        
        foam_mask_primary = smoothstep(foam_cutoff + 0.5, foam_cutoff + 0.6, combined_noise);
        float shadow_shape = smoothstep(foam_cutoff + 0.5, foam_cutoff + 0.6, combined_shadow);
        foam_mask_shadow = clamp(shadow_shape - foam_mask_primary, 0.0, 1.0);
    }
    
    float voronoi_val = 1.0 - sqrt(voronoi(world_vert.xz * voronoi_scale + warp));
    voronoi_val = smoothstep(0.2, 0.8, voronoi_val);
    float bubble_alpha = 1.0 - clamp((1.0 - voronoi_val) * voronoi_strength, 0.0, 1.0);
    
    // Blend final foam layers into the material output channels
    ALBEDO = mix(ALBEDO, foam_edge_color, foam_mask_shadow);
    ALBEDO = mix(ALBEDO, foam_color, foam_mask_primary * bubble_alpha);
    
    // Output PBR parameters
    ROUGHNESS = mix(roughness, 0.8, (foam_mask_primary * bubble_alpha) + foam_mask_shadow);
    METALLIC = metallic;
    SPECULAR = specular;
}