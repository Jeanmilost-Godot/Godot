shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4  color_a:         source_color          = vec4(0.1, 0.5, 1.0, 1.0);
uniform vec4  color_b:         source_color          = vec4(1.0, 0.1, 0.6, 1.0);
uniform vec4  albedo_color:    source_color          = vec4(1.0, 1.0, 1.0, 1.0);

uniform float pulse_speed:     hint_range(0.0, 10.0) = 1.5;
uniform float emission_energy: hint_range(0.0, 20.0) = 3.0;
uniform float min_intensity:   hint_range(0.0, 1.0)  = 0.0;  // floor so it doesn't go fully dark
uniform bool  use_smooth_pulse                       = true; // sine vs triangle wave

varying float v_pulse;

float triangle_wave(float t)
{
    return abs(fract(t) * 2.0 - 1.0);
}

void fragment()
{
    float t = TIME * pulse_speed;
    float pulse;

    if (use_smooth_pulse)
        // 0..1 smooth
        pulse = (sin(t * TAU) * 0.5) + 0.5;
    else
        // 0..1 linear ping-pong
        pulse = triangle_wave(t);

    pulse = mix(min_intensity, 1.0, pulse);

    vec4 mixed_color = mix(color_a, color_b, pulse);

    ALBEDO   = albedo_color.rgb;
    EMISSION = mixed_color.rgb * emission_energy;
}
