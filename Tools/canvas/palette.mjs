// Colour arithmetic for the palette exploration boards: OKLCH to sRGB, ramps, and contrast.
// OKLCH is lightness (0–1), chroma (colourfulness) and hue (degrees), spaced to match how the eye sees them,
// so even steps of lightness look even. Imported by build.mjs.
//
// The arithmetic is kept as source text, COLOUR_JS, so the colour grid board can run the same code live in its own
// script when the user picks a colour; this module runs it once and exports the functions.

export const COLOUR_JS = String.raw`
var toLinear = function (c) { return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); };
var toGamma = function (c) { return c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1 / 2.4) - 0.055; };

// OKLCH → linear sRGB, unclipped (a channel outside 0–1 means the screen cannot show the colour).
function linearRGB(L, C, H) {
  var a = C * Math.cos((H * Math.PI) / 180), b = C * Math.sin((H * Math.PI) / 180);
  var l = Math.pow(L + 0.3963377774 * a + 0.2158037573 * b, 3);
  var m = Math.pow(L - 0.1055613458 * a - 0.0638541728 * b, 3);
  var s = Math.pow(L - 0.0894841775 * a - 1.2914855480 * b, 3);
  return [
    4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
  ];
}
function inGamut(rgb) { return rgb.every(function (c) { return c >= -1e-4 && c <= 1 + 1e-4; }); }

function hex(L, C, H) {
  return '#' + linearRGB(L, C, H).map(function (c) { return ('0' + Math.round(Math.min(1, Math.max(0, toGamma(c))) * 255).toString(16)).slice(-2); }).join('').toUpperCase();
}

// The most chroma the screen can show at this lightness and hue.
function maxChroma(L, H) {
  var lo = 0, hi = 0.4;
  for (var i = 0; i < 30; i++) { var mid = (lo + hi) / 2; if (inGamut(linearRGB(L, mid, H))) lo = mid; else hi = mid; }
  return lo;
}

// A ramp: one hue, the given lightness steps, chroma held at the role's own unless the screen cannot show it there,
// which eases it toward the light and dark ends.
function ramp(role, steps) {
  return steps.map(function (L) { var C = Math.min(role.chroma, 0.95 * maxChroma(L, role.hue)); return { L: L, C: C, H: role.hue, hex: hex(L, C, role.hue) }; });
}

function rgb(h) { return [1, 3, 5].map(function (i) { return parseInt(h.slice(i, i + 2), 16) / 255; }); }
function luminance(h) { var c = rgb(h).map(toLinear); return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]; }
function contrast(a, b) { var x = luminance(a), y = luminance(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
// A colour at an opacity over a ground, as the solid colour the eye sees.
function over(fg, bg, alpha) {
  var f = rgb(fg), g = rgb(bg);
  return '#' + f.map(function (c, i) { return ('0' + Math.round((c * alpha + g[i] * (1 - alpha)) * 255).toString(16)).slice(-2); }).join('').toUpperCase();
}

// A hex colour in OKLCH: its lightness, chroma and hue.
function oklch(h) {
  var c = rgb(h).map(toLinear), r = c[0], g = c[1], b = c[2];
  var l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  var m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  var s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  var L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
  var A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
  var B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
  return { L: L, C: Math.hypot(A, B), H: ((Math.atan2(B, A) * 180) / Math.PI + 360) % 360 };
}

// A ramp built around a colour: its hue and chroma, the given steps, and the colour itself in place of the nearest
// step, exactly as it is.
function rampAround(anchor, steps) {
  var a = oklch(anchor);
  var near = steps.reduce(function (best, L) { return Math.abs(L - a.L) < Math.abs(best - a.L) ? L : best; }, steps[0]);
  return ramp({ hue: a.H, chroma: a.C }, steps).map(function (s) { return s.L === near ? { L: a.L, C: a.C, H: a.H, hex: anchor.toUpperCase(), anchor: true } : s; });
}
`;

const lib = new Function(`${COLOUR_JS}\nreturn { hex, ramp, contrast, over, oklch, rampAround };`)();
export const { hex, ramp, contrast, over, oklch, rampAround } = lib;
