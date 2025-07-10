shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, depth_test_disabled, specular_schlick_ggx;

uniform float time_scale:      hint_range(0.1, 5.0)  = 1.0;
uniform float flame_intensity: hint_range(0.1, 3.0)  = 2.0;
uniform vec4  inner_color:     source_color          = vec4(1.0, 0.9, 0.2, 1.0);
uniform vec4  outer_color:     source_color          = vec4(1.0, 0.2, 0.0, 0.6);
uniform float noise_scale:     hint_range(1.0, 10.0) = 4.0;

varying vec3 world_position;
varying vec3 local_position;

float hash(vec3 p)
{
    p  = fract(p * 0.3183099 + 0.1);
    p *= 17.0;

    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise3d(vec3 p)
{
    vec3 i = floor(p);
    vec3 f = fract(p);
    f      = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
                   mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
                   mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y), f.z);
}

void vertex()
{
    world_position = VERTEX;
    local_position = VERTEX;
}

void fragment()
{
    float time = TIME * time_scale;
    vec3  pos  = local_position * noise_scale + vec3(0.0, time * 2.0, 0.0);
    
    float noise_val = 0.0;
    float amplitude = 1.0;

    for (int i = 0; i < 4; ++i)
	{
        noise_val += amplitude * noise3d(pos);
        pos       *= 2.0;
        amplitude *= 0.5;
    }
    
    float dist        = length(local_position);
    float sphere_mask = 1.0 - smoothstep(0.8, 1.2, dist);
    
    float flame_mask = sphere_mask * noise_val * flame_intensity;
    flame_mask       = max(0.0, flame_mask);
    
    vec4 flame_color  = mix(outer_color, inner_color, flame_mask);
    flame_color.a    *= sphere_mask * (0.3 + 0.7 * noise_val);
    
    ALBEDO   = flame_color.rgb;
    ALPHA    = flame_color.a;
    EMISSION = flame_color.rgb * 2.0;
}
