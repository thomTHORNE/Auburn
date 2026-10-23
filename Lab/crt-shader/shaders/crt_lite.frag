#version 460 core

// Lab probe: CRT shader over Flutter. Throwaway code — see Lab/Log.md.
// Lite variant: the same pass with half the bloom taps and a one-octave smudge.

#include <flutter/runtime_effect.glsl>

// Set by the engine for ImageFilter.shader; set by hand for the sampler path.
uniform vec2 u_size;
uniform sampler2D u_texture;

// Float uniforms 2, 3, and 4.
uniform float u_time;
uniform float u_strength;
// 1 runs the time-based effects (rolling band, grain); 0 holds the picture still.
uniform float u_animate;

out vec4 frag_color;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

vec3 tap(vec2 uv) {
  return texture(u_texture, uv).rgb;
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

  // Chromatic aberration: half the first pass, and none in the middle where values sit.
  vec2 dir = cc * 0.0035 * s * smoothstep(0.15, 0.5, length(ccA));
  vec3 col = vec3(texture(u_texture, buv + dir).r,
                  texture(u_texture, buv).g,
                  texture(u_texture, buv - dir).b);

  // Bloom: two rings of taps, added where the picture is bright.
  vec2 p1 = 2.0 / u_size;
  vec3 near = (tap(buv + vec2(p1.x, p1.y)) + tap(buv - vec2(p1.x, p1.y))) * 0.5;
  float bright = max(near.r, max(near.g, near.b));
  col += near * 0.35 * s * smoothstep(0.15, 0.8, bright);

  // Scanlines: a fixed count, so both render paths match.
  float scan = 0.88 + 0.12 * sin(uv.y * 220.0 * 6.2831853);
  col *= mix(1.0, scan, s);

  // A slow rolling band.
  float band = exp(-pow((fract(uv.y * 0.5 - u_time * 0.05) - 0.5) * 12.0, 2.0));
  col += band * 0.02 * s * u_animate;

  // Vignette.
  float vig = smoothstep(0.85, 0.25, length(ccA));
  col *= mix(1.0, 0.55 + 0.45 * vig, s);

  // Glass halo, upper left.
  vec2 hp = (uv - vec2(0.22, 0.10)) * vec2(aspect, 1.0);
  col += vec3(0.86, 0.97, 0.96) * exp(-dot(hp, hp) * 18.0) * 0.06 * s;

  // Smudges, kept away from the middle of the screen.
  float edge = smoothstep(0.18, 0.55, length(ccA));
  float smudge = smoothstep(0.55, 0.85, noise(uv * vec2(3.0, 5.0) + 7.3));
  col += vec3(0.80, 0.85, 0.80) * smudge * edge * 0.05 * s;

  // Grain.
  col += (hash(FlutterFragCoord().xy + fract(u_time) * 100.0) - 0.5) * 0.03 * s * u_animate;

  // Black beyond the tube's curved edge.
  vec2 inside = step(vec2(0.0), buv) * step(buv, vec2(1.0));
  col *= inside.x * inside.y;

  frag_color = vec4(col, 1.0);
}
