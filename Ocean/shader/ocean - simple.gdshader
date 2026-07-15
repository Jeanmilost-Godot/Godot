shader_type spatial;
//REM render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform float max_depth : hint_range(0.1, 50.0, 0.1) = 10.0; // max depth to visualize
uniform float water_level : hint_range(-10.0, 10.0, 0.1) = 0.0; // base height of the water surface

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 underwater_fog_color : source_color = vec3(0.0, 0.05, 0.1);
uniform float fade_start_depth : hint_range(0.0, 50.0, 0.1) = 0.5;

// wave parameters
uniform float sea_height : hint_range(0.0, 5.0) = 1.3;
uniform float sea_choppy : hint_range(0.0, 10.0) = 4.0;
uniform float sea_speed : hint_range(0.0, 5.0) = 1.5;
uniform float sea_freq : hint_range(0.0, 0.5) = 0.08;

// iterations
uniform int ITER_GEOMETRY = 3;
uniform int ITER_FRAGMENT = 5;
const mat2 octave_m = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));

// refraction settings
uniform float refraction_strength : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float refraction_distance_fade : hint_range(0.0, 100.0, 1.0) = 5.0;

//for smoothness part
uniform float normal_epsilon : hint_range(0.001, 1.0) = 0.01;
uniform float normal_smoothness_dist : hint_range(0.0, 1000.0) = 50.0;

uniform vec3 base_tint_color : source_color = vec3(0.439, 0.973, 1.0);
uniform vec3 deep_color : source_color = vec3(0.0, 0.341, 0.29);

// beer-lambert absorption
uniform vec3 water_absorption : source_color = vec3(0.3, 0.06, 0.02);

uniform float roughness : hint_range(0.0, 1.0) = 0.125;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0) = 0.5;

// caustics uniforms
uniform sampler2D caustics_texture : filter_linear_mipmap, repeat_enable;
uniform float caustics_scale : hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float caustics_speed : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float caustics_intensity : hint_range(0.0, 2.0, 0.1) = 0.8;
uniform float caustics_depth_fade : hint_range(0.0, 1.0, 0.01) = 0.7;

varying vec3 world_vert;
varying float wave_height;
varying vec3 vertex_normal_world;

float hash12(vec2 p) {
    uvec2 q = uvec2(ivec2(p)) * uvec2(1597334677u, 3812015801u);
    uint n = (q.x ^ q.y) * 1597334677u;
    return float(n) * (1.0 / 4294967295.0);
}

float noise(in vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return -1.0 + 2.0 * mix(mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
                            mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x), u.y);
}

float sea_octave(vec2 uv, float choppy) {
    uv += noise(uv);
    vec2 wv = 1.0 - abs(sin(uv));
    vec2 swv = abs(cos(uv));
    wv = mix(wv, swv, wv);
    return pow(1.0 - pow(wv.x * wv.y, 0.65), choppy);
}

float map(vec3 p, float time) {
    float freq = sea_freq;
    float amp = sea_height;
    float choppy = sea_choppy;
    vec2 uv = p.xz;
    uv.x *= 0.75;
    float h = 0.0;
    for (int i = 0; i < ITER_GEOMETRY; i++) {
        float d = sea_octave((uv + time * sea_speed) * freq, choppy);
        d += sea_octave((uv - time * sea_speed) * freq, choppy);
        h += d * amp;
        uv *= octave_m;
        freq *= 1.9;
        amp *= 0.22;
        choppy = mix(choppy, 1.0, 0.2);
    }
    return p.y - h;
}

float map_detailed(vec3 p, float time) {
    float freq = sea_freq;
    float amp = sea_height;
    float choppy = sea_choppy;
    vec2 uv = p.xz;
    uv.x *= 0.75;
    float h = 0.0;
    for (int i = 0; i < ITER_FRAGMENT; i++) {
        float d = sea_octave((uv + time * sea_speed) * freq, choppy);
        d += sea_octave((uv - time * sea_speed) * freq, choppy);
        h += d * amp;
        uv *= octave_m;
        freq *= 1.9;
        amp *= 0.22;
        choppy = mix(choppy, 1.0, 0.2);
    }
    return p.y - h;
}

vec3 get_normal_detailed(vec3 p, float eps, float time) {
    vec3 n;
    n.y = map_detailed(p, time);
    n.x = map_detailed(vec3(p.x + eps, p.y, p.z), time) - n.y;
    n.z = map_detailed(vec3(p.x, p.y, p.z + eps), time) - n.y;
    n.y = eps;
    return normalize(n);
}

// GET LINEAR DEPTH FROM DEPTH TEXTURE
float get_linear_depth(sampler2D d_tex, vec2 uv, mat4 inv_proj, bool outputIsSRGB) {
    float depth = texture(d_tex, uv).x;
    vec3 ndc = vec3(uv * 2.0 - 1.0, depth);

    if (outputIsSRGB) {
        ndc.z = depth * 2.0 - 1.0;
    }

    vec4 view = inv_proj * vec4(ndc, 1.0);
    return -view.z / view.w;
}

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    wave_height = -map(world_pos, TIME);
    VERTEX.y = wave_height;
    world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float vertex_eps = 0.1;
    float h_center = wave_height;
    float h_x = -map(world_pos + vec3(vertex_eps, 0.0, 0.0), TIME);
    float h_z = -map(world_pos + vec3(0.0, 0.0, vertex_eps), TIME);
    vec3 n_geom = normalize(vec3(h_center - h_x, vertex_eps, h_center - h_z));
    vertex_normal_world = n_geom;
}

void fragment() {
    /*REM
    float lod_epsilon = 0.01;
    vec3 detailed_normal = get_normal_detailed(world_vert, lod_epsilon, TIME);
    NORMAL = (VIEW_MATRIX * vec4(detailed_normal, 0.0)).xyz;
    */
    // normals & distance smoothing
    float dist_to_cam = length(VERTEX);
    float lod_epsilon = max(normal_epsilon, dist_to_cam * 0.005);
    vec3 detailed_normal = get_normal_detailed(world_vert, lod_epsilon, TIME);
    float smooth_factor = clamp((dist_to_cam - normal_smoothness_dist) / 200.0, 0.0, 1.0);
    vec3 final_normal = mix(detailed_normal, vertex_normal_world, smooth_factor);
    NORMAL = (VIEW_MATRIX * vec4(final_normal, 0.0)).xyz;

    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;

    vec3 ndc;
    if (OUTPUT_IS_SRGB) {
        // Compatibility (OpenGL) uses a [-1, 1] Z range for NDC
        ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
    } else {
        // Forward+ and Mobile (Vulkan) use a [0, 1] Z range for NDC
        ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
    }

    // use inverse matrices to transform from screen space to world space.
    vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    vec3 world_pos = world.xyz / world.w;

    float surface_y = water_level;

    // calculate water depth/thickness
    // subtract the world position Y from the surface Y.
    //REM float thickness = surface_y - world_pos.y; // REM?

    //REM thickness = max(0.0, thickness); // clamp to 0 so areas above water are black //REM?

    // linear depth of the water surface itself
    float water_linear_depth = -VERTEX.z;

    // linear depth of what's behind the water
    float bg_linear_depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);
    float thickness = max(0.0, bg_linear_depth - water_linear_depth);

    // refraction offset calculation
    vec3 view_vertex_normal = (VIEW_MATRIX * vec4(vertex_normal_world, 0.0)).xyz;
    vec2 normal_offset = NORMAL.xy - view_vertex_normal.xy;
    float ref_dist_factor = clamp(refraction_distance_fade / max(0.1, dist_to_cam), 0.0, 1.0);
    float ref_depth_mask = smoothstep(0.0, max_depth, thickness);
    vec2 refraction_offset = normal_offset * refraction_strength * ref_dist_factor * ref_depth_mask * 0.05;

    vec2 distorted_uv = SCREEN_UV + refraction_offset;

    // fix ghosting for pixels that are on boundary so they dont make water look weird
    float distorted_bg_depth = get_linear_depth(DEPTH_TEXTURE, distorted_uv, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);

    if (distorted_bg_depth < water_linear_depth - 0.001) {
        distorted_uv = SCREEN_UV;
        distorted_bg_depth = bg_linear_depth;
    }

    vec3 screen_color = texture(SCREEN_TEXTURE, distorted_uv).rgb;
    thickness = max(0.0, distorted_bg_depth - water_linear_depth);

    //REM vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    float fade_range = max(0.001, max_depth - fade_start_depth);
    float depth_ratio = clamp((thickness - fade_start_depth) / fade_range, 0.0, 1.0);

    ALBEDO = mix(screen_color, underwater_fog_color, depth_ratio);

    // caustics
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

    vec3 transmittance = exp(-thickness * water_absorption);
    vec3 water_volume_color = mix(base_tint_color, deep_color, depth_ratio);
    vec3 apparent_seabed_color = screen_color * water_volume_color; // screen_color = seabed color
    ALBEDO = mix(underwater_fog_color, apparent_seabed_color, transmittance);

    ROUGHNESS = roughness;
    METALLIC = metallic;
    SPECULAR = specular;
}
