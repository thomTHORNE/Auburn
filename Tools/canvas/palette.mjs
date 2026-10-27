// Colour arithmetic for the palette exploration board: OKLCH to sRGB, ramps, and contrast.
// OKLCH is lightness (0–1), chroma (colourfulness) and hue (degrees), spaced to match how the eye sees them,
// so even steps of lightness look even. Imported by build.mjs.

const toLinear = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const toGamma = (c) => (c <= 0.0031308 ? 12.92 * c : 1.055 * c ** (1 / 2.4) - 0.055);

// OKLCH → linear sRGB, unclipped (a channel outside 0–1 means the screen cannot show the colour).
function linearRGB(L, C, H) {
  const a = C * Math.cos((H * Math.PI) / 180), b = C * Math.sin((H * Math.PI) / 180);
  const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
  const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
  const s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3;
  return [
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
}
const inGamut = (rgb) => rgb.every((c) => c >= -1e-4 && c <= 1 + 1e-4);

export function hex(L, C, H) {
  return '#' + linearRGB(L, C, H).map((c) => Math.round(Math.min(1, Math.max(0, toGamma(c))) * 255).toString(16).padStart(2, '0')).join('').toUpperCase();
}

// The most chroma the screen can show at this lightness and hue.
function maxChroma(L, H) {
  let lo = 0, hi = 0.4;
  for (let i = 0; i < 30; i++) { const mid = (lo + hi) / 2; if (inGamut(linearRGB(L, mid, H))) lo = mid; else hi = mid; }
  return lo;
}

// A ramp: one hue, the given lightness steps, chroma held at the role's own unless the screen cannot show it there,
// which eases it toward the light and dark ends.
export function ramp({ hue, chroma }, steps) {
  return steps.map((L) => { const C = Math.min(chroma, 0.95 * maxChroma(L, hue)); return { L, C, H: hue, hex: hex(L, C, hue) }; });
}

const rgb = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
const luminance = (h) => { const [r, g, b] = rgb(h).map(toLinear); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
export const contrast = (a, b) => { const [x, y] = [luminance(a), luminance(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };
// A colour at an opacity over a ground, as the solid colour the eye sees.
export const over = (fg, bg, alpha) => '#' + rgb(fg).map((c, i) => Math.round((c * alpha + rgb(bg)[i] * (1 - alpha)) * 255).toString(16).padStart(2, '0')).join('').toUpperCase();

// A hex colour in OKLCH: its lightness, chroma and hue.
export function oklch(h) {
  const [r, g, b] = rgb(h).map(toLinear);
  const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  const L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
  const A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  const B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
  return { L, C: Math.hypot(A, B), H: ((Math.atan2(B, A) * 180) / Math.PI + 360) % 360 };
}

// A ramp built around a colour: its hue and chroma, the given steps, and the colour itself in place of the nearest
// step, exactly as it is.
export function rampAround(anchor, steps) {
  const a = oklch(anchor);
  const near = steps.reduce((best, L) => (Math.abs(L - a.L) < Math.abs(best - a.L) ? L : best), steps[0]);
  return ramp({ hue: a.H, chroma: a.C }, steps).map((s) => (s.L === near ? { L: a.L, C: a.C, H: a.H, hex: anchor.toUpperCase(), anchor: true } : s));
}
