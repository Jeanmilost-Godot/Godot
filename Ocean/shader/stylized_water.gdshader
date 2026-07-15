shader_type spatial;
render_mode specular_toon;

// =============================================================
// STYLIZED WATER SHADER
// Depth-based underwater fog, FBM wave displacement, screen-space
// refraction, Beer-Lambert absorption and Voronoi-based foam.
// =============================================================

// ---- core textures ----
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ---- surface / depth ----
uniform float water_level : hint_range(-10.0, 10.0, 0.1) = 0.0;
uniform float max_visible_depth : hint_range(0.1, 60.0, 0.1) = 12.0;

// ---- wave shape ----
uniform float wave_amplitude : hint_range(0.0, 5.0) = 1.2;
uniform float wave_sharpness : hint_range(0.0, 10.0) = 3.5;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.4;
uniform float wave_base_freq : hint_range(0.0, 0.5) = 0.09;
uniform int wave_octaves_vertex : hint_range(1, 8) = 3;
uniform int wave_octaves_fragment : hint_range(1, 8) = 5;
const mat2 OCTAVE_ROT = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));

// ---- color / absorption ----
uniform vec3 shallow_color : source_color = vec3(0.45, 0.95, 1.0);
uniform vec3 deep_color : source_color = vec3(0.0, 0.3, 0.28);
uniform vec3 fog_color : source_color = vec3(0.0, 0.05, 0.1);
uniform vec3 absorption_rgb : source_color = vec3(0.3, 0.06, 0.02);
uniform float fog_start_depth : hint_range(0.0, 50.0, 0.1) = 0.5;

// ---- refraction ----
uniform float refraction_amount : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float refraction_max_range : hint_range(0.0, 100.0) = 5.0;
uniform float normal_epsilon_min : hint_range(0.001, 1.0) = 0.01;
uniform float normal_lod_distance : hint_range(0.0, 1000.0) = 50.0;

// ---- PBR ----
uniform float surface_roughness : hint_range(0.0, 1.0) = 0.12;
uniform float surface_metallic : hint_range(0.0, 1.0) = 0.0;
uniform float surface_specular : hint_range(0.0, 1.0) = 0.5;

// ---- foam ----
uniform vec3 foam_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 foam_shadow_tint : source_color = vec3(0.0, 0.0, 0.05);
uniform float foam_shore_depth : hint_range(0.0, 5.0, 0.01) = 0.8;
uniform float foam_crest_level : hint_range(0.0, 1.0, 0.01) = 0.72;
uniform float foam_crest_boost : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float foam_scale : hint_range(0.0, 10.0, 0.01) = 2.2;
uniform float foam_flow_speed : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float foam_threshold : hint_range(0.0, 1.0, 0.01) = 0.65;
uniform vec2 foam_shadow_offset = vec2(0.025, 0.025);
uniform float bubble_scale : hint_range(0.0, 50.0) = 9.0;
uniform float bubble_strength : hint_range(0.0, 8.0) = 0.8;

varying vec3 v_world_pos;
varying float v_wave_y;
varying vec3 v_geom_normal;

// ---------------------------------------------------------------
// Hash / noise utilities
// ---------------------------------------------------------------
float hash1(vec2 p) {
    p = fract(p * vec2(123.45, 678.91));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 hash2(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    q += dot(q, q.yzx + 33.33);
    return fract((q.xx + q.yz) * q.zy);
}

float hash3(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash1(i);
    float b = hash1(i + vec2(1.0, 0.0));
    float c = hash1(i + vec2(0.0, 1.0));
    float d = hash1(i + vec2(1.0, 1.0));
    return -1.0 + 2.0 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float value_noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = hash3(i);
    float n100 = hash3(i + vec3(1, 0, 0));
    float n010 = hash3(i + vec3(0, 1, 0));
    float n110 = hash3(i + vec3(1, 1, 0));
    float n001 = hash3(i + vec3(0, 0, 1));
    float n101 = hash3(i + vec3(1, 0, 1));
    float n011 = hash3(i + vec3(0, 1, 1));
    float n111 = hash3(i + vec3(1, 1, 1));
    return mix(
        mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
        mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y),
        f.z);
}

// single ripple lobe used to build the wave field
float ripple_lobe(vec2 uv, float sharpness) {
    uv += value_noise(uv);
    vec2 a = 1.0 - abs(sin(uv));
    vec2 b = abs(cos(uv));
    vec2 blended = mix(a, b, a);
    return pow(1.0 - pow(blended.x * blended.y, 0.65), sharpness);
}

// summed wave height field, returns signed distance from plane p.y
float wave_field(vec3 p, float t, int octaves) {
    float freq = wave_base_freq;
    float amp = wave_amplitude;
    float sharp = wave_sharpness;
    vec2 uv = p.xz;
    uv.x *= 0.75;
    float h = 0.0;
    for (int i = 0; i < octaves; i++) {
        float lobe = ripple_lobe((uv + t * wave_speed) * freq, sharp);
        lobe += ripple_lobe((uv - t * wave_speed) * freq, sharp);
        h += lobe * amp;
        uv = OCTAVE_ROT * uv;
        freq *= 1.9;
        amp *= 0.22;
        sharp = mix(sharp, 1.0, 0.2);
    }
    return p.y - h;
}

vec3 wave_normal(vec3 p, float eps, float t) {
    float h_center = wave_field(p, t, wave_octaves_fragment);
    float h_x = wave_field(p + vec3(eps, 0.0, 0.0), t, wave_octaves_fragment) - h_center;
    float h_z = wave_field(p + vec3(0.0, 0.0, eps), t, wave_octaves_fragment) - h_center;
    return normalize(vec3(-h_x, eps, -h_z));
}

// voronoi cell distance, cells animate slightly for organic foam movement
float voronoi(vec2 uv, float anim_speed) {
    vec2 cell = floor(uv);
    vec2 local = fract(uv);
    float best = 1.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 offset = vec2(float(i), float(j));
            vec2 rnd = hash2(cell + offset);
            rnd = 0.5 + 0.5 * sin(TIME * anim_speed + 6.2831 * rnd);
            vec2 diff = offset - local + rnd;
            best = min(best, dot(diff, diff));
        }
    }
    return best;
}

float foam_fbm(vec2 uv) {
    float total = 0.0;
    float amp = 0.5;
    vec2 offset = vec2(37.0, 91.0);
    mat2 rot = mat2(vec2(cos(0.6), sin(0.6)), vec2(-sin(0.6), cos(0.6)));
    for (int i = 0; i < 3; i++) {
        float cell_val = 1.0 - voronoi(uv, foam_flow_speed);
        cell_val = pow(cell_val, 2.0);
        total += amp * cell_val;
        uv = rot * uv * 2.0 + offset;
        amp *= 0.5;
    }
    return total;
}

// reconstruct linear view-space depth from the depth buffer, handling
// the Compatibility (OpenGL, [-1,1] Z) vs Forward+/Mobile (Vulkan, [0,1] Z)
// NDC convention difference at runtime via OUTPUT_IS_SRGB.
float linear_depth_at(vec2 uv, mat4 inv_proj, bool outputIsSRGB) {
    float raw_depth = texture(DEPTH_TEXTURE, uv).x;
    vec3 ndc = vec3(uv * 2.0 - 1.0, raw_depth);
    if (outputIsSRGB) {
        ndc.z = raw_depth * 2.0 - 1.0;
    }
    vec4 view_pos = inv_proj * vec4(ndc, 1.0);
    return -view_pos.z / view_pos.w;
}

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v_wave_y = wave_field(world_pos, TIME, wave_octaves_vertex) * -1.0;
    VERTEX.y = v_wave_y;
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    float eps = 0.1;
    float h_x = wave_field(world_pos + vec3(eps, 0.0, 0.0), TIME, wave_octaves_vertex) * -1.0;
    float h_z = wave_field(world_pos + vec3(0.0, 0.0, eps), TIME, wave_octaves_vertex) * -1.0;
    v_geom_normal = normalize(vec3(v_wave_y - h_x, eps, v_wave_y - h_z));
}

void fragment() {
    // --- detailed normal with distance-based LOD to avoid specular shimmer ---
    float dist_to_cam = length(VERTEX);
    float lod_eps = max(normal_epsilon_min, dist_to_cam * 0.005);
    vec3 detail_normal = wave_normal(v_world_pos, lod_eps, TIME);
    float lod_blend = clamp((dist_to_cam - normal_lod_distance) / 200.0, 0.0, 1.0);
    vec3 final_normal = mix(detail_normal, v_geom_normal, lod_blend);
    NORMAL = (VIEW_MATRIX * vec4(final_normal, 0.0)).xyz;

    // --- background depth / thickness ---
    float water_view_depth = -VERTEX.z;
    float bg_view_depth = linear_depth_at(SCREEN_UV, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
    float thickness = max(0.0, bg_view_depth - water_view_depth);

    // --- refraction offset, masked by distance and depth ---
    vec3 view_geom_normal = (VIEW_MATRIX * vec4(v_geom_normal, 0.0)).xyz;
    vec2 normal_delta = NORMAL.xy - view_geom_normal.xy;
    float dist_mask = clamp(refraction_max_range / max(0.1, dist_to_cam), 0.0, 1.0);
    float depth_mask = smoothstep(0.0, max_visible_depth, thickness);
    vec2 refraction_offset = normal_delta * refraction_amount * dist_mask * depth_mask * 0.05;
    vec2 sample_uv = SCREEN_UV + refraction_offset;

    // discard refraction where it would peek across a silhouette edge
    float refracted_bg_depth = linear_depth_at(sample_uv, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
    if (refracted_bg_depth < water_view_depth - 0.001) {
        sample_uv = SCREEN_UV;
        refracted_bg_depth = bg_view_depth;
    }
    thickness = max(0.0, refracted_bg_depth - water_view_depth);

    vec3 seabed_color = texture(SCREEN_TEXTURE, sample_uv).rgb;

    // --- shading tint + Beer-Lambert absorption ---
    float fade_range = max(0.001, max_visible_depth - fog_start_depth);
    float depth_ratio = clamp((thickness - fog_start_depth) / fade_range, 0.0, 1.0);
    vec3 volume_tint = mix(shallow_color, deep_color, depth_ratio);
    vec3 transmittance = exp(-thickness * absorption_rgb);
    vec3 apparent_color = seabed_color * volume_tint;
    ALBEDO = mix(fog_color, apparent_color, transmittance);

    ROUGHNESS = surface_roughness;
    METALLIC = surface_metallic;
    SPECULAR = surface_specular;

    // --- foam ---
    float shore_factor = smoothstep(foam_shore_depth, 0.0, thickness);
    float crest_factor = smoothstep(foam_crest_level, foam_crest_level - 0.1, final_normal.y) * foam_crest_boost;
    float foam_potential = clamp(shore_factor + crest_factor, 0.0, 1.0);

    vec2 flow_offset = vec2(
        value_noise(v_world_pos.xz * 0.5 + TIME * 0.05 * foam_flow_speed),
        value_noise(v_world_pos.xz * 0.5 + TIME * 0.05 * foam_flow_speed + vec2(5.2, 1.3))
    ) * 0.5;

    float foam_mask = 0.0;
    float foam_shadow_mask = 0.0;

    if (refracted_bg_depth > water_view_depth) {
        vec2 foam_uv = v_world_pos.xz * foam_scale + flow_offset;
        float emergence = value_noise3(vec3(v_world_pos.xz * 0.5, TIME * 0.2 * foam_flow_speed));
        emergence = smoothstep(-1.0, 1.0, emergence);
        emergence = mix(emergence, 1.0, foam_potential);

        float foam_val = foam_fbm(foam_uv) * emergence;
        vec2 shadow_uv = (v_world_pos.xz + foam_shadow_offset) * foam_scale + flow_offset;
        float shadow_val = foam_fbm(shadow_uv) * emergence;

        float foam_combined = foam_val + foam_potential;
        float shadow_combined = shadow_val + foam_potential;

        foam_mask = smoothstep(foam_threshold + 0.5, foam_threshold + 0.6, foam_combined);
        float shadow_shape = smoothstep(foam_threshold + 0.5, foam_threshold + 0.6, shadow_combined);
        foam_shadow_mask = clamp(shadow_shape - foam_mask, 0.0, 1.0);
    }

    float bubbles = 1.0 - sqrt(voronoi(v_world_pos.xz * bubble_scale + flow_offset, foam_flow_speed));
    bubbles = smoothstep(0.2, 0.8, bubbles);
    float bubble_alpha = 1.0 - clamp((1.0 - bubbles) * bubble_strength, 0.0, 1.0);

    ALBEDO = mix(ALBEDO, foam_shadow_tint, foam_shadow_mask);
    ALBEDO = mix(ALBEDO, foam_tint, foam_mask * bubble_alpha);
    ROUGHNESS = mix(surface_roughness, 0.8, (foam_mask * bubble_alpha) + foam_shadow_mask);
}
