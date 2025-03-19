#version 320 es

// Flutter Material Ink Sparkle Shader
precision highp float;

// Input from Dart code
uniform vec4 u_color;
uniform float u_alpha;
uniform vec2 u_resolution;
uniform vec2 u_center;
uniform float u_radius;
uniform float u_time;
uniform float u_maximum_sparkle_radius;
uniform float u_sparkle_alpha;
uniform float u_sparkle_phase_1;
uniform float u_sparkle_phase_2;
uniform float u_sparkle_phase_3;

// Output
out vec4 fragColor;

// Constants
const float PI = 3.1415926535897932384626433832795;
const int SPARKLE_COUNT = 8;

// Random function
float random(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// Sparkle function
float sparkle(vec2 position, float time, float phase) {
    float angle = phase * 2.0 * PI;
    vec2 displacement = vec2(cos(angle), sin(angle)) * u_maximum_sparkle_radius;
    float distance = length(position - (u_center + displacement));
    float sparkle_radius = u_radius * 0.3;
    
    // Fade based on time and distance
    float fade = max(0.0, 1.0 - (time * 2.0));
    float brightness = max(0.0, 1.0 - pow(distance / sparkle_radius, 2.0)) * fade;
    
    return brightness * u_sparkle_alpha;
}

void main() {
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 position = fragCoord.xy / u_resolution.xy;
    position.x *= u_resolution.x / u_resolution.y;
    
    // Distance from center
    float dist = length(fragCoord - u_center);
    
    // Base color with alpha
    vec4 color = u_color * u_alpha;
    
    // Add sparkles if within radius
    if (dist < u_radius) {
        // Calculate sparkle contribution
        float sparkle_sum = 0.0;
        float phases[SPARKLE_COUNT];
        phases[0] = u_sparkle_phase_1;
        phases[1] = u_sparkle_phase_2;
        phases[2] = u_sparkle_phase_3;
        
        // Generate other phases
        for (int i = 3; i < SPARKLE_COUNT; i++) {
            phases[i] = random(vec2(float(i), u_time));
        }
        
        // Add all sparkles
        for (int i = 0; i < SPARKLE_COUNT; i++) {
            sparkle_sum += sparkle(fragCoord, u_time, phases[i]);
        }
        
        // Add sparkle to color
        color.rgb += sparkle_sum * vec3(1.0);
    }
    
    fragColor = color;
}