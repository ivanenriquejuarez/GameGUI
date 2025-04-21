shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.2, 0.0, 1.0);
uniform float speed = 2.0;
uniform float intensity = 0.5;

void fragment() {
    vec4 text_color = texture(TEXTURE, UV);

    // Create flame effect
    float flame = sin(UV.y * 10.0 + TIME * speed) * intensity;
    vec4 final_color = mix(base_color, flame_color, flame);

    COLOR = text_color * final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
