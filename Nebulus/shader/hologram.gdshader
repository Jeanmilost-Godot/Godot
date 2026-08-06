shader_type spatial;
render_mode blend_add, unshaded, cull_back;

uniform vec4  albedo:            source_color            = vec4(0.1, 0.7, 1.0, 1.0);
uniform float rim_power:         hint_range(0.0, 10.0)   = 3.0;
uniform float scanline_speed:    hint_range(-20.0, 20.0) = 8.0;
uniform float scanline_density:  hint_range(1.0, 200.0)  = 50.0;
uniform float flicker_speed:     hint_range(0.0, 50.0)   = 15.0;
uniform float flicker_intensity: hint_range(0.0, 1.0)    = 0.1;
uniform float alpha_multiplier:  hint_range(0.0, 1.0)    = 0.6;

void fragment()
{
    // rim lighting (edges glow brighter)
    float rim = 1.0 - dot(VIEW, NORMAL);
    rim       = pow(rim, rim_power);
    
    // scanlines moving vertically
    float scanline = sin((VERTEX.y * scanline_density) + (TIME * scanline_speed));
    scanline       = 0.7 + (1.0 - 0.7) * ((scanline - (-1.0)) / (1.0 - (-1.0)));
    
    // slight random flicker
    float flicker = 1.0 - (sin(TIME * flicker_speed) * flicker_intensity);
    
    // Final color and transparency calculation
    vec3  finalColor = albedo.rgb * rim * scanline * flicker;
    float finalAlpha = (rim + 0.2) * alpha_multiplier * flicker;
    
    ALBEDO = finalColor;
    ALPHA = clamp(finalAlpha, 0.0, 1.0);
}
