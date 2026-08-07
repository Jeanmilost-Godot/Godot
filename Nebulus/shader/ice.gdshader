shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

// Color and Transparency
uniform vec4 ice_color : source_color = vec4(0.4, 0.75, 0.9, 0.2);
uniform vec4 frost_color : source_color = vec4(0.95, 0.98, 1.0, 0.9);
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.15;
uniform float rim_intensity : hint_range(0.0, 5.0) = 2.0;

// Refraction (Gives the glass/ice cylinder depth look)
uniform float refraction_strength : hint_range(-0.1, 0.1) = 0.03;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Ice Shell & Icicles (Stalactites)
uniform float ice_thickness : hint_range(0.0, 0.2) = 0.03;
uniform float icicle_length : hint_range(0.0, 1.0) = 0.4;
uniform float icicle_sharpness : hint_range(1.0, 10.0) = 4.0;

// Textures
uniform sampler2D noise_tex : repeat_enable, filter_linear_mipmap;
uniform sampler2D normal_bump_tex : hint_normal, repeat_enable;
uniform vec3 uv_scale = vec3(2.0, 2.0, 2.0);

varying vec3 world_normal;

void vertex() {
	// FIXED: Calculate world normal using the built-in MODEL_NORMAL_MATRIX
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	
	// Sample noise based on object vertex positions
	float noise = texture(noise_tex, VERTEX.xz * uv_scale.xy).r;
	
	// Base thickness expansion
	float displacement = ice_thickness;
	
	// Mask out the bottom surfaces (where world_normal.y is negative)
	float bottom_mask = clamp(-world_normal.y, 0.0, 1.0);
	
	// Sharpen the noise to create pointy icicle shapes
	float icicle_shape = pow(noise, icicle_sharpness);
	
	// Push vertices downward along the global Y axis on bottom surfaces
	VERTEX.y -= icicle_shape * icicle_length * bottom_mask;
	
	// Apply normal displacement for standard surfaces
	VERTEX += NORMAL * displacement * (1.0 - bottom_mask);
}

void fragment() {
	// Sample realistic ice surface bumps
	vec3 normal_map = texture(normal_bump_tex, UV * uv_scale.xy).rgb;
	NORMAL_MAP = normal_map;
	
	// Fresnel / Rim lighting for icy edges
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
	float rim = pow(1.0 - dot(NORMAL, VIEW), 5.0) * rim_intensity;
	
	// Sample noise for frost distribution
	float frost_noise = texture(noise_tex, UV * uv_scale.xy).r;
	
	// Realistic Screen Space Refraction
	vec2 refracted_uv = SCREEN_UV + (NORMAL.xy * refraction_strength);
	vec3 refraction_color = texture(SCREEN_TEXTURE, refracted_uv).rgb;
	
	// Mix base transparency with ice color
	vec3 base_ice = mix(refraction_color, ice_color.rgb, ice_color.a);
	
	// Overlay frost maps and rim lighting
	vec3 final_albedo = mix(base_ice, frost_color.rgb, frost_noise * 0.3 + fresnel * 0.5);
	final_albedo += frost_color.rgb * rim;
	
	ALBEDO = final_albedo;
	ALPHA = clamp(ice_color.a + fresnel * 0.7 + rim, 0.0, 1.0);
	ROUGHNESS = mix(roughness, roughness * 3.0, frost_noise); // Frost is rougher than smooth ice
	METALLIC = metallic;
}
