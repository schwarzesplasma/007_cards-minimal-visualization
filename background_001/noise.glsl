// noise.glsl
// Pixel shader for an animated procedural background.
//
// Big idea:
// 1) For each screen pixel, compute a UV coordinate (0..1).
// 2) Sample procedural value-noise in 3D (x, y, time).
// 3) Optionally sample a second noise layer and blend it in.
// 4) Map noise value (0..1) to a color gradient (low -> high).

// Current screen size in pixels (sent from Lua).
extern vec2 u_resolution;
// Random per-seed offset (sent from Lua on create/regenerate).
extern vec2 u_seedOffset;
// Elapsed animation time (bounded in Lua with fmod).
extern float u_time;

// Layer 1 controls.
extern float u_noiseScale1;
extern float u_morphSpeed1;
extern float u_driftSpeed1;
extern vec2 u_driftDir1;

// Layer 2 controls (optional).
extern float u_layer2Enabled;
extern float u_noiseScale2;
extern float u_morphSpeed2;
extern float u_driftSpeed2;
extern vec2 u_driftDir2;
extern float u_layer2Blend;
extern float u_warpScale;
extern float u_warpStrength;
extern float u_warpSpeed;
extern float u_fbmStrength;
extern float u_fbmScale;
extern float u_fbmSpeed;
extern float u_fbmOctaves;
extern float u_fbmGain;
extern float u_fbmLacunarity;
extern vec4 u_noiseColor;

// Gradient colors for final output.
extern vec4 u_lowColor;
extern vec4 u_highColor;

// Hash function:
// Converts a 3D point into a pseudo-random value in [0, 1).
// Deterministic: same input point always returns the same output.
float hash13(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

// 3D value noise (smooth interpolation of random lattice values).
// Input: vec3(x, y, z) where z acts like "time axis" for morphing.
// Output: smooth noise value in approximately [0, 1].
float valueNoise3D(vec3 p) {
    // Integer cell origin in XY and Z for current point.
    vec2 i = floor(p.xy);
    float iz = floor(p.z);

    // Fractional position inside the cell.
    vec2 f = fract(p.xy);
    float fz = fract(p.z);

    // Sample random values at the 8 corners of the surrounding 3D cell.
    float a0 = hash13(vec3(i, iz));
    float b0 = hash13(vec3(i + vec2(1.0, 0.0), iz));
    float c0 = hash13(vec3(i + vec2(0.0, 1.0), iz));
    float d0 = hash13(vec3(i + vec2(1.0, 1.0), iz));
    float a1 = hash13(vec3(i, iz + 1.0));
    float b1 = hash13(vec3(i + vec2(1.0, 0.0), iz + 1.0));
    float c1 = hash13(vec3(i + vec2(0.0, 1.0), iz + 1.0));
    float d1 = hash13(vec3(i + vec2(1.0, 1.0), iz + 1.0));

    // Smoothstep-like interpolation weights for smoother transitions.
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Interpolate within the z-slice at iz.
    float n0 = mix(a0, b0, u.x) + (c0 - a0) * u.y * (1.0 - u.x) + (d0 - b0) * u.x * u.y;
    // Interpolate within the z-slice at iz+1.
    float n1 = mix(a1, b1, u.x) + (c1 - a1) * u.y * (1.0 - u.x) + (d1 - b1) * u.x * u.y;

    // Interpolate between the two z-slices -> produces morphing over time.
    float uz = fz * fz * (3.0 - 2.0 * fz);
    return mix(n0, n1, uz);
}

float fbm3D(vec3 p, float octaves, float gain, float lacunarity) {
    float sum = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    float norm = 0.0;

    for (int i = 0; i < 8; i++) {
        if (float(i) >= octaves) {
            break;
        }

        sum += valueNoise3D(vec3(p.xy * frequency, p.z * frequency)) * amplitude;
        norm += amplitude;
        amplitude *= gain;
        frequency *= lacunarity;
    }

    if (norm <= 0.0) {
        return 0.5;
    }

    return sum / norm;
}

// Pixel shader entry point (called once per pixel).
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    // Normalize pixel position into UV space (0..1 across the screen).
    vec2 uv = screen_coords / u_resolution;

    // Seed offset changes pattern between regenerations.
    vec2 base = uv + u_seedOffset;

    // Domain warp: use two independent noise probes to distort sample coordinates.
    // This bends the "noise space" and makes the result feel more organic.
    float warpTime = u_time * u_warpSpeed;
    float wx = valueNoise3D(vec3(base * u_warpScale + vec2(13.1, 71.7), warpTime));
    float wy = valueNoise3D(vec3(base * u_warpScale + vec2(91.3, 29.5), warpTime + 17.0));
    vec2 warp = (vec2(wx, wy) * 2.0 - 1.0) * u_warpStrength;
    vec2 warpedBase = base + warp;

    // Layer 1:
    // - noiseScale controls detail frequency
    // - drift moves the sample point over time in a direction
    // - morph uses time as the z-axis in 3D noise (shape evolution)
    vec2 p1 = warpedBase * u_noiseScale1 + u_driftDir1 * (u_time * u_driftSpeed1);
    float n1 = valueNoise3D(vec3(p1, u_time * u_morphSpeed1));

    // Start with layer 1 result.
    float n = n1;

    // Optional layer 2 with independent controls, then blended with layer 1.
    if (u_layer2Enabled > 0.5) {
        vec2 p2 = warpedBase * u_noiseScale2 + u_driftDir2 * (u_time * u_driftSpeed2);
        float n2 = valueNoise3D(vec3(p2, u_time * u_morphSpeed2));
        n = mix(n1, n2, clamp(u_layer2Blend, 0.0, 1.0));
    }

    // Optional fBm overlay on top of the existing noise result.
    if (u_fbmStrength > 0.0) {
        vec2 fbmP = warpedBase * u_fbmScale;
        float fbmN = fbm3D(vec3(fbmP, u_time * u_fbmSpeed), u_fbmOctaves, u_fbmGain, u_fbmLacunarity);
        // Add centered detail so the base structure remains recognizable.
        n = clamp(n + (fbmN - 0.5) * u_fbmStrength, 0.0, 1.0);
    }

    // Convert noise value to final color.
    vec4 baseColor = mix(u_lowColor, u_highColor, n);

    // Colorize the noise directly by multiplying with a chosen noise color.
    // This is not a screen tint/overlay; it changes the noise color itself.
    return vec4(baseColor.rgb * u_noiseColor.rgb, baseColor.a * u_noiseColor.a);
}
