#version 460 core

// Lab sketch: Glass that moves. Throwaway code — see Lab/Log.md.
// The CRT probe's shader, with the glass layer driven from outside: the halo
// sits where the app puts it. Film, swipe streaks, and dust stay
// fixed on the glass and show where the light catches them.

#include <flutter/runtime_effect.glsl>

// Set by the engine for ImageFilter.shader.
uniform vec2 u_size;
uniform sampler2D u_texture;

// Float uniforms 2 to 7.
uniform float u_time;
uniform float u_strength;
// 1 runs the time-based effects (rolling band, grain); 0 holds the picture still.
uniform float u_animate;
// Halo centre, in screen fractions.
uniform vec2 u_light;
// How much glass: 0 none, 0.6 low, 1.2 high.
uniform float u_glass;

out vec4 frag_color;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

// Sine-free hash, so large coordinates stay stable on mobile GPUs.
vec2 hash22(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.xx + p3.yz) * p3.zy) * 2.0 - 1.0;
}

// Gradient noise with a quintic fade: no visible grid, unlike value noise.
// Roughly -0.7 to 0.7.
float gnoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
  float a = dot(hash22(i), f);
  float b = dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
  float c = dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
  float d = dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Each octave is rotated, so no layer lines up with the screen's axes.
float fbm(vec2 p) {
  const mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
  float v = 0.0;
  float a = 0.5;
  for (int k = 0; k < 4; k++) {
    v += a * gnoise(p);
    p = rot * p * 2.03 + 17.1;
    a *= 0.5;
  }
  return v;
}

mat2 rotation(float a) {
  float c = cos(a);
  float s = sin(a);
  return mat2(c, s, -s, c);
}

// Sampling stays one pixel inside the picture, so nothing past its edge leaks in.
vec3 tap(vec2 uv) {
  vec2 px = 1.0 / u_size;
  return texture(u_texture, clamp(uv, px, 1.0 - px)).rgb;
}

void main() {
  vec2 uv = FlutterFragCoord().xy / u_size;
  float s = u_strength;
  float aspect = u_size.x / u_size.y;

  vec2 cc = uv - 0.5;
  vec2 ccA = cc * vec2(aspect, 1.0);
  float r2 = dot(ccA, ccA);

  // Curvature: sample further out toward the edges, so the picture bulges.
  vec2 buv = 0.5 + cc * (1.0 + 0.06 * s * r2);

  // Chromatic aberration, none in the middle where values sit.
  vec2 dir = cc * 0.0035 * s * smoothstep(0.15, 0.5, length(ccA));
  vec3 col = vec3(tap(buv + dir).r, tap(buv).g, tap(buv - dir).b);

  // Bloom: two rings of taps, added where the picture is bright.
  vec2 p1 = 2.0 / u_size;
  vec2 p2 = 7.0 / u_size;
  vec3 near = (tap(buv + vec2(p1.x, 0.0)) + tap(buv - vec2(p1.x, 0.0)) +
               tap(buv + vec2(0.0, p1.y)) + tap(buv - vec2(0.0, p1.y))) * 0.25;
  vec3 far = (tap(buv + p2) + tap(buv - p2) +
              tap(buv + vec2(p2.x, -p2.y)) + tap(buv + vec2(-p2.x, p2.y))) * 0.25;
  float bright = max(far.r, max(far.g, far.b));
  col += (near * 0.25 + far * 0.35) * 0.6 * s * smoothstep(0.15, 0.8, bright);

  // Scanlines.
  float scan = 0.88 + 0.12 * sin(uv.y * 220.0 * 6.2831853);
  col *= mix(1.0, scan, s);

  // A slow rolling band.
  float band = exp(-pow((fract(uv.y * 0.5 - u_time * 0.05) - 0.5) * 12.0, 2.0));
  col += band * 0.02 * s * u_animate;

  // Vignette.
  float vig = smoothstep(0.85, 0.25, length(ccA));
  col *= mix(1.0, 0.55 + 0.45 * vig, s);

  // The glass. Everything on it is placed in screen space, not on the curved
  // picture, and in glass units so shapes are not stretched by the aspect.
  vec2 g = uv * vec2(aspect, 1.0);
  vec3 light = vec3(0.86, 0.97, 0.96);

  // The reflection: a bright core inside a broad, faint sheen.
  vec2 hp = (uv - u_light) * vec2(aspect, 1.0);
  float h2 = dot(hp, hp);
  float halo = exp(-h2 * 18.0);
  float sheen = exp(-h2 * 2.5);
  col += light * (halo * 0.08 + sheen * 0.02) * u_glass * s;

  // Oily film: domain-warped noise, so patches have soft, irregular edges.
  vec2 warp = vec2(fbm(g * 2.0 + 1.7), fbm(g * 2.0 + 9.2));
  float film = smoothstep(0.0, 0.35, fbm(g * 3.0 + warp * 1.2 + 4.0));

  // Swipe streaks: noise stretched along a direction that bends across the
  // glass, the way a thumb drags. Only some patches carry them.
  float angle = 0.35 * sin(g.y * 2.0 + 1.0) + 0.6 * gnoise(g * 1.5 + 3.0);
  vec2 sq = rotation(angle) * g * vec2(38.0, 7.0);
  float streak = smoothstep(0.1, 0.5, gnoise(sq) + 0.25 * gnoise(sq * vec2(1.0, 3.0) + 5.0))
               * smoothstep(0.0, 0.4, gnoise(g * 3.0 + 11.0));

  // Dust: sparse specks, jittered inside their cells so no grid shows.
  vec2 cell = floor(g * 60.0);
  vec2 rnd = hash22(cell + 5.0) * 0.5 + 0.5;
  vec2 spot = (cell + 0.2 + 0.6 * (hash22(cell + 9.0) * 0.5 + 0.5)) / 60.0;
  float dust = step(0.96, rnd.x) * smoothstep(1.6, 0.4, length(g - spot) * u_size.y);

  // Smudges are mostly invisible until the light catches them.
  float caught = 0.12 + 2.2 * halo + 0.6 * sheen;
  float centre = 0.35 + 0.65 * smoothstep(0.12, 0.5, length(ccA));
  float dirt = film * 0.035 + streak * 0.05 + dust * 0.3;
  col += light * dirt * caught * centre * u_glass * s;

  // Where the film is, the picture underneath softens slightly.
  col = mix(col, col * 0.7 + near * 0.3, film * caught * centre * 0.15 * u_glass * s);

  // Grain.
  col += (hash(FlutterFragCoord().xy + fract(u_time) * 100.0) - 0.5) * 0.03 * s * u_animate;

  // Black beyond the tube's curved edge, feathered over three pixels.
  vec2 feather = 3.0 / u_size;
  vec2 inside = smoothstep(vec2(0.0), feather, buv) * smoothstep(vec2(0.0), feather, 1.0 - buv);
  col *= inside.x * inside.y;

  frag_color = vec4(col, 1.0);
}
