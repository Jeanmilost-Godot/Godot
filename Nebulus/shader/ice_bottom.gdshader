shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx;

// Color and Transparency (Cinematic Ice Look)
uniform vec4 ice_color : source_color = vec4(0.3, 0.65, 0.85, 0.3);
uniform vec4 frost_color : source_color = vec4(0.9, 0.95, 1.0, 0.9);
uniform float roughness : hint_range(0.0, 1.0) = 0.05;
uniform float metallic : hint_range(0.0, 1.0) = 0.1;
uniform float rim_intensity : hint_range(0.0, 5.0) = 2.5;

// Refraction Setup
uniform float refraction_strength : hint_range(-0.1, 0.1) = 0.04;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Ocean-Style Geometry Deformation
uniform float ice_depth : hint_range(0.0, 2.0) = 0.8; // Total height/length of spikes
uniform float spike_sharpness : hint_range(0.5, 5.0) = 3.0; // Higher = pointier icicles
uniform vec2 uv_scale = vec2(3.0, 3.0);

// Textures
uniform sampler2D noise_tex : repeat_enable, filter_linear_mipmap;
uniform sampler2D normal_bump_tex : hint_normal, repeat_enable;

// Varying variables pass data smoothly from vertex to fragment calculations
varying float vertex_height;
varying vec2 world_uv;

void vertex() {
	// 1. Calculate the unique 3D world position of this specific vertex in your level
	vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	
	// 2. Map the X and Z world coordinates into our UV scale
	// Adding world_pos.y ensures that even if platforms are stacked directly above each other, they stay unique!
	world_uv = (world_pos.xz + vec2(world_pos.y * 12.34)) * uv_scale;
	
	// 3. Sample heightmap noise layers for organic variation
	float noise_layer1 = texture(noise_tex, world_uv).r;
	float noise_layer2 = texture(noise_tex, world_uv * 2.5).r * 0.5;
	
	// Combine layers (Ocean-style Fractal Brownian Motion)
	float combined_noise = noise_layer1 + noise_layer2;
	
	// Invert and sharpen the noise mathematically to create steep, narrow peaks (icicles)
	float sharp_peaks = pow(combined_noise, spike_sharpness);
	
	// Displace the vertices downward along the local Y axis
	VERTEX.y -= sharp_peaks * ice_depth;
	
	// Pass the height data to the fragment shader for visual highlights
	vertex_height = sharp_peaks;
}

void fragment() {
	// Sample an ice-surface normal map using our unique world position coordinates
	vec3 normal_map = texture(normal_bump_tex, world_uv).rgb;
	NORMAL_MAP = normal_map;
	
	// Fresnel / Rim lighting (makes the tips and edges glow like the photo)
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
	float rim = pow(1.0 - dot(NORMAL, VIEW), 4.0) * rim_intensity;
	
	// Sample noise for surface frost texturing using the exact same world coordinates
	float frost_noise = texture(noise_tex, world_uv).r;
	
	// Screen space refraction for that beautiful semi-translucent glass look
	vec2 refracted_uv = SCREEN_UV + (NORMAL.xy * refraction_strength);
	vec3 refraction_color = texture(SCREEN_TEXTURE, refracted_uv).rgb;
	
	// Blend the refracted background with the deep blue ice color
	vec3 base_ice = mix(refraction_color, ice_color.rgb, ice_color.a);
	
	// Mix frost maps onto the peaks based on both vertex height and the raw noise map
	float frost_mask = smoothstep(0.2, 0.8, vertex_height) * frost_noise;
	vec3 final_albedo = mix(base_ice, frost_color.rgb, frost_mask * 0.5 + fresnel * 0.4);
	final_albedo += frost_color.rgb * rim;
	
	ALBEDO = final_albedo;
	ALPHA = clamp(ice_color.a + fresnel * 0.6 + rim, 0.0, 1.0);
	ROUGHNESS = mix(roughness, roughness * 4.0, frost_mask); // Tips are frostier/rougher
	METALLIC = metallic;
}
