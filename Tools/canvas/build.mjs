// Builds the canvas boards that are generated rather than drawn, into the mirror at Canvas/project/.
//
//   Theme.dc.html            the Theme board: every agreed screen, a tweak for every basic except the tube's,
//                            and the swatches; the changed list, hold-to-preview and the change log.
//   C-<Name>, C-<Name>-States each agreed component (Spec/Visual Design/components/<name>/component.html), with a
//                            tweak for each property, and a board showing its states.
//   S01-R3-Round.dc.html     screen 01's round 3 board: the same, for round 3's states, plus the trials below.
//   S00-Dark, S00-Light      the agreed boot (Spec/Visual Design/00-boot/screen.html), held frame, line 0.
//   S01-<state>              the agreed screen 01 (Spec/Visual Design/01-navigation/screen.html), importing the
//                            component boards.
//   S01-R3-<state>           screen 01, round 3: its own copy of the agreed screen and its components, flattened,
//                            moved onto the trial scales and text colours, with tap areas of the trial's height,
//                            and a state of its own: a full-width widget edited.
//   basics.css               a copy of Spec/Visual Design/basics.css.
//
// Values the user has set in a board's Tweaks tab are read from the mirror and kept. A change stays on its board.
// It also updates Canvas/project/canvas.json: the Theme page, each board's entry (a board the user moved keeps
// its place), and the order. Run from the repository root: node Tools/canvas/build.mjs
// Then commit and publish the changed files as CLAUDE.md's The canvas says.

import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'node:fs';
import { components } from '../build-components.mjs';

const SPEC = 'Spec/Visual Design';
const OUT = 'Canvas/project';
const BUST = '/_blob/8dc69cd32a565ee54c5606a82fce2b14'; // the traced bust, uploaded to the canvas
// The bust on the canvas is a mask over the accent, so it follows the theme.
const MASK_CSS = `.bust{background: var(--color-accent); -webkit-mask: url(${BUST}) center top / contain no-repeat; mask: url(${BUST}) center top / contain no-repeat}`;
let COMPONENT_CSS = '';

// Named colours to try anything with, on every board with tweaks. Never basics: a swatch that is kept joins the
// palette under a name first.
const SWATCH_LIST = [['--trial-a', '#76DA84'], ['--trial-b', '#D9573B'], ['--trial-c', '#D9573B'], ['--trial-d', '#D9573B']];

// Round 3's trials: values screen 01's round 3 is trying that are not basics yet.
const TRIALS = [
  ['Type scale', [
    ['--text-1', '11px'], ['--text-1-tracking', '0.5px'], ['--text-1-leading', '15px'],
    ['--text-2', '13px'], ['--text-2-tracking', '2px'], ['--text-2-leading', '11px'],
    ['--text-3', '16px'], ['--text-3-tracking', '1.5px'], ['--text-3-leading', '20px'],
    ['--text-4', '22px'], ['--text-4-tracking', '6px'], ['--text-4-leading', '24px'],
  ]],
  // Each emphasis level's text takes its colour from the palette or a swatch, by name; its opacity stays the level's.
  ['Text colour', [
    ['--color-primary-text', 'var(--ember)'], ['--color-secondary-text', 'var(--ember)'], ['--color-supporting-text', 'var(--ember)'],
  ]],
  ['Spacing scale', [
    ['--space-1', '2px'], ['--space-2', '4px'], ['--space-3', '8px'],
    ['--space-4', '12px'], ['--space-5', '16px'], ['--space-6', '24px'],
  ]],
  // The least height a key's tap area takes, Android's 48 dp.
  ['Tap area', [['--tap-area', '48px']]],
];

// Screen 01's sizes, as they were before the scales, and the step each moves to.
const TEXT_STEP = { 10: 1, 11: 1, 13: 2, 16: 3, 22: 4 };
const SPACE_STEP = { 2: 1, 4: 2, 6: 3, 7: 3, 8: 3, 10: 4, 12: 4, 16: 5, 18: 5, 24: 6 };

// ---- basics.css ----

function parseBasics(path) {
  const groups = [];
  let group = null;
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    if (/^\[data-theme="light"\]/.test(line)) { group = { name: 'Light theme', light: true, tokens: [] }; groups.push(group); continue; }
    const g = line.match(/^\s*\/\*\s*([A-Z][^(*]*?)\s*(\(.*)?\*\/\s*$/);
    if (g) { group = { name: g[1].split(':')[0].trim(), tokens: [] }; groups.push(group); continue; }
    for (const m of line.matchAll(/(--[a-z0-9-]+):\s*([^;]+);/g)) group.tokens.push([m[1], m[2].trim()]);
  }
  return groups;
}

const key = (css) => css.slice(2).replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
const keyOf = (t) => (t.light ? `light${cap(key(t.css))}` : key(t.css));

// A token's Tweaks editor, its value as the editor holds it, and how that value is written back as CSS.
function editorFor(css, value, section) {
  // A reference picks from the tier below: a palette colour or a swatch, a family, a semantic colour, a level.
  const ref = value.match(/^var\(--([a-z0-9-]+)\)$/);
  if (ref) {
    const options = [[...PALETTE, ...SWATCHES], FAMILIES, SEMANTIC_COLORS, LEVELS].find((o) => o.includes(ref[1]));
    if (options) return { meta: { editor: 'enum', options, default: ref[1], section }, unit: '', ref: true };
  }
  if (/^#[0-9a-f]{6}$/i.test(value)) return { meta: { editor: 'color', default: value.toUpperCase(), section }, unit: '' };
  if (/-weight$/.test(css)) return { meta: { editor: 'enum', options: ['400', '700'], default: value, section }, unit: '' };
  let m = value.match(/^([\d.]+)%$/);
  if (m) return { meta: { editor: 'range', default: +m[1], min: 0, max: 100, step: 1, unit: '%', section }, unit: '%' };
  m = value.match(/^([\d.]+)s$/);
  if (m) return { meta: { editor: 'range', default: +m[1], min: 0.1, max: 5, step: 0.1, unit: 's', section }, unit: 's' };
  m = value.match(/^([\d.]+)px$/);
  if (m) {
    const [min, max, step] = /-line-width$/.test(css) ? [1, 6, 1] : /-tracking$/.test(css) ? [0, 10, 0.5]
      : /^--space-/.test(css) ? [0, 48, 1] : [6, 48, 1];
    return { meta: { editor: 'range', default: +m[1], min, max, step, unit: 'px', section }, unit: 'px' };
  }
  return { meta: { editor: 'text', default: value, section }, unit: '' };
}

const basics = parseBasics(`${SPEC}/basics.css`).filter((g) => !/tube/i.test(g.name));
const names = (group) => basics.find((g) => g.name === group).tokens.map(([css]) => css.slice(2));
const PALETTE = names('Palette');
const FAMILIES = names('Font families');
const SEMANTIC_COLORS = names('Colour');
const LEVELS = ['primary-text', 'secondary-text', 'supporting-text'];
const SWATCHES = SWATCH_LIST.map(([css]) => css.slice(2));
const basicTokens = [];
// The light theme's values share their names with the dark ones; their tweaks are kept apart.
for (const g of basics) for (const [css, v] of g.tokens) basicTokens.push({ css, start: v, trial: false, light: !!g.light, ...editorFor(css, v, g.name) });
const swatchTokens = SWATCH_LIST.map(([css, v]) => ({ css, start: v, trial: true, ...editorFor(css, v, 'Swatches · trial') }));
const roundTokens = [];
for (const [name, list] of TRIALS) for (const [css, v] of list) roundTokens.push({ css, start: v, trial: true, ...editorFor(css, v, `${name} · trial`) });

// ---- the mirror ----

function readProps(path) {
  if (!existsSync(path)) return {};
  // The editor may save the attribute double-quoted, with its quotes as entities.
  const m = readFileSync(path, 'utf8').match(/data-props=(?:'([^']*)'|"([^"]*)")/);
  if (!m) return {};
  return JSON.parse((m[1] ?? m[2]).replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, '&'));
}

const attr = (obj) => JSON.stringify(obj).replace(/&/g, '&amp;').replace(/'/g, '&#39;');

function board({ title, fonts, helmet = '', body, script, props }) {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>${title}</title>
<script src="./support.js"></script>
<link rel="stylesheet" href="basics.css">
</head>
<body>
<x-dc>
<helmet>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?${fonts}&amp;display=swap">
<style>
body{margin:0}
${helmet}
${COMPONENT_CSS}
</style>
</helmet>
${body}
</x-dc>
<script type="text/x-dc" data-dc-script data-props='${attr(props)}'>
${script}
</script>
</body>
</html>
`;
}

// A screen board takes the Theme board's values through `theme`; on its own it shows the basics and its trials.
const screenScript = (defaults) => `class Component extends DCLogic {
renderVals() {
// Values passed in by the Theme board; on its own, the board's trials over basics.css.
return { theme: this.props.theme != null ? this.props.theme : ${JSON.stringify(defaults)} };
}
}`;

const RENAMED = { primaryTextColor: 'colorPrimaryText', secondaryTextColor: 'colorSecondaryText', supportingTextColor: 'colorSupportingText' };
const vars = (list) => list.map((t) => `${t.css}: ${t.start}`).join('; ');

// ---- screen 00, the boot: agreed, held frame ----

function bootBoards() {
  const src = readFileSync(`${SPEC}/00-boot/screen.html`, 'utf8');
  const css = src.match(/<style>([\s\S]*?)<\/style>/)[1];
  // The boot's own rules, scoped to its board, without the timeline: the held frame.
  const rules = css
    .replace(/@keyframes[^{]+\{(?:[^{}]*\{[^}]*\})*[^}]*\}/g, '')
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/^\s*body\s*\{[^}]*\}\s*$/m, '')
    .replace(/:root\s*\{/, '.b00{')
    .replace(/\[data-theme="(dark|light)"\]/g, '.b00-$1')
    .replace(/\.(screen|power-line|picture|dots|stack|plate|rule-outer|rule-inner|pillars|pillar|line|wordmark|still)\b/g, '.b00-$1')
    .replace(/animation:[^;]+;/g, '')
    .split('\n').map((l) => l.trim()).filter(Boolean).join('\n');
  const markup = src.match(/<div class="screen">([\s\S]*?)<\/div>\s*<script>/)[1]
    .replace(/<div class="power-line"[^>]*><\/div>/, '')
    .replace(/class="([a-z-]+)"/g, (_, c) => `class="${c.split(' ').map((x) => `b00-${x}`).join(' ')}"`)
    .replace('<span id="line"></span>', '<span>More human than human.</span>');
  const out = {};
  for (const theme of ['dark', 'light']) {
    out[`S00-${theme === 'dark' ? 'Dark' : 'Light'}.dc.html`] = board({
      title: `Boot · ${theme} · agreed`,
      fonts: 'family=Gelasio:wght@700&amp;family=Saira:wght@300;600',
      helmet: rules,
      body: `<div class="b00 b00-${theme} b00-screen" data-theme="${theme}" style="{{theme}}">${markup}</div>`,
      script: screenScript(''),
      props: { theme: { editor: null }, $preview: { width: 400, height: 640 } },
    });
  }
  return out;
}

// ---- screen 01, round 3: the agreed screen on the scales ----

const spaceVar = (px) => (SPACE_STEP[px] ? `var(--space-${SPACE_STEP[px]})` : null);
const leftovers = {};

function onScales(style) {
  let s = style;
  // Text: size, tracking and leading all come from the size's step.
  const fs = s.match(/font-size: (\d+)px/);
  if (fs && TEXT_STEP[fs[1]]) {
    const n = TEXT_STEP[fs[1]];
    s = s.replace(/font-size: \d+px/, `font-size: var(--text-${n})`)
      .replace(/;?\s*letter-spacing: [\d.]+px/, '').replace(/;?\s*line-height: [\d.]+px/, '');
    s = `${s.replace(/;\s*$/, '')}; letter-spacing: var(--text-${n}-tracking); line-height: var(--text-${n}-leading)`;
  }
  // Weight follows the emphasis level of the element's own colour.
  const lvl = s.match(/color: color-mix\(in srgb, var\(--color-accent\) var\(--(primary|secondary|supporting)-text\)/);
  if (lvl) s = s.replace(/font-weight: \d+/, `font-weight: var(--${lvl[1]}-text-weight)`);
  // Text takes its level's colour.
  s = s.replace(/var\(--color-accent\) var\(--(primary|secondary|supporting)-text\)/g, 'var(--color-$1-text) var(--$1-text)');
  // Lines take their level's width.
  s = s.replace(/(border(?:-top|-bottom|-left|-right)?): \d+px solid (color-mix\(in srgb, var\(--color-accent\) var\(--(primary|secondary|supporting)-line\))/g,
    (_, p, mix, l) => `${p}: var(--${l}-line-width) solid ${mix}`);
  // Gaps, padding and margins take steps of the spacing scale; negative margins stay as they are.
  s = s.replace(/\b((?:row-|column-)?gap|padding(?:-[a-z]+)?|margin(?:-[a-z]+)?): ([^;"]+)/g, (all, p, v) => {
    if (/-\d|--tap-area/.test(v)) return all;
    return `${p}: ${v.replace(/(?<![\d.])(\d+)px\b/g, (px, n) => {
      // The power key's text lines up with the entries' text: the margin, the glyph, the glyph's gap.
      if (p === 'padding' && n === '50') return 'calc(var(--space-5) + 18px + var(--space-5))';
      if (spaceVar(n)) return spaceVar(n);
      leftovers[`${p} ${px}`] = (leftovers[`${p} ${px}`] || 0) + 1;
      return px;
    })}`;
  });
  // The content's inset from the screen's edges.
  s = s.replace(/\b(left|right): 16px/g, '$1: var(--space-5)').replace(/\btop: 18px/, 'top: var(--space-5)');
  return s;
}

// Every key takes a tap area of the trial's height, the way EDIT does: an invisible button around the key it shows,
// its overhang taken back by a negative margin, so the key looks and sits as before. At half width the editing keys
// take two rows, ▲ ▼ over HALF FULL, each key wide enough to tap; the rows sit far enough apart that their tap
// areas do not overlap.
const overhang = (key) => `calc((${key} - var(--tap-area)) / 2)`;
function tapAreas(html) {
  return html
    .replace(/height: 44px; margin: -9px -8px -9px 0;/g, `height: var(--tap-area); margin: ${overhang('26px')} -8px ${overhang('26px')} 0;`)
    .replace(/<button (aria-label="Move (?:up|down)") style="height: 30px; (border: [^;]+); background: transparent; (color: [^;]+); font-family: inherit; ([^"]+)" type="button">(.)<\/button>/g,
      (_, label, border, color, type, key) => `<button ${label} style="height: var(--tap-area); margin: ${overhang('30px')} 0; padding: 0; border: none; background: transparent; display: flex; align-items: center; font-family: inherit" type="button">`
        + `<span style="flex: 1; height: 30px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; ${border}; ${color}; ${type}">${key}</span></button>`)
    .replace(/<span class="seg seg-(half|full)" style="([^"]+)">(HALF|FULL)<\/span>/g,
      (_, w, st, key) => `<button aria-label="${cap(w)} width" style="flex: 1; height: var(--tap-area); margin: ${overhang('26px')} 0; padding: 0; border: none; background: transparent; display: flex; align-items: center; font: inherit; color: inherit; letter-spacing: inherit" type="button">`
        + `<span class="seg seg-${w}" style="${st}; height: 26px">${key}</span></button>`)
    .replace(/(class="widget w-half"[\s\S]*?class="edit-controls" style="display: grid; grid-template-columns: )repeat\(4, minmax\(0, 1fr\)\); gap: 6px/g,
      '$1repeat(2, minmax(0, 1fr)); gap: 24px 6px');
}

// ---- components ----

const COMPONENTS = components();
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);
const boardOf = (tag) => `C-${cap(tag.replace('auburn-', ''))}`;
const camel = (s) => s.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
const attrsOf = (s) => Object.fromEntries([...s.matchAll(/([a-z0-9-]+)="([^"]*)"/g)].map(([, k, v]) => [k, v]));
const ALL_CSS = COMPONENTS.map((c) => c.css).filter(Boolean).join('\n');
// Every board carries every component's rules: a board shown inside another takes only the outer board's rules.
// An import's host takes the part of the component's own element: out of the layout, or filling its placing.
const CONTENTS = COMPONENTS.filter((c) => /display: contents/.test(c.css)).map((c) => `.sc-host:has(> .${c.tag})`).join(', ');
const FILLED = COMPONENTS.filter((c) => !/display: contents/.test(c.css)).map((c) => `.sc-host:has(> .${c.tag}), .sc-host > .${c.tag}`).join(', ');
// A component's own board, shown alone, stands on the screen's ground as it would on a screen.
const ALONE = '#dc-root > .sc-host:has(> [class^="auburn-"]) { background: var(--color-ground); color: var(--color-accent); font-family: var(--font-interface); overflow: hidden; }';
COMPONENT_CSS = `${ALL_CSS}\n${MASK_CSS}\na{color:inherit}\n${CONTENTS} { display: contents; }\n${FILLED} { height: 100%; }\n${ALONE}`;
const bustToMask = (html) => html.replace(/<img alt="" class="bust" src="[^"]*" style="([^"]*)"\/?>/g, '<div class="bust" aria-hidden="true" style="$1"></div>');

// The same filling as components.js, for a round's flattened copy.
function fill(html, data) {
  const look = (path, d) => path.split('.').reduce((o, k) => (o == null ? o : o[k]), d);
  const esc = (v) => String(v == null ? '' : v).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  html = html.replace(/<template data-each="([a-z0-9]+)">([\s\S]*?)<\/template>/g, (_, name, inner) => {
    let list = data[name];
    if (typeof list === 'string') list = list ? list.split('|') : [];
    return (list || []).map((item) => fill(inner, { ...data, item })).join('');
  });
  return html.replace(/\{\{([a-z0-9.]+)\}\}/g, (_, path) => esc(look(path, data)));
}
let uid = 0;
function expand(html) {
  return html.replace(/<(auburn-[a-z]+)((?:\s+[a-z0-9-]+="[^"]*")*)\s*><\/\1>/g, (_, tag, attrs) => {
    const c = COMPONENTS.find((x) => x.tag === tag);
    const a = attrsOf(attrs);
    const data = { assets: '', uid: `r${++uid}` };
    for (const [k, v] of Object.entries(a)) if (k.startsWith('data-')) data[camel(k.slice(5))] = v;
    if (c.logic) Object.assign(data, new Function(`return (${c.logic})`)()(data));
    return `<div class="${tag}"${attrs}>${expand(fill(c.html, data))}</div>`;
  });
}

// An element placing a component becomes an import of its board; its data attributes become the board's props.
function toImports(html) {
  return html.replace(/<(auburn-[a-z]+)((?:\s+[a-z0-9-]+="[^"]*")*)\s*><\/\1>/g, (_, tag, attrs) => {
    const a = attrsOf(attrs);
    const props = Object.entries(a).filter(([k]) => k.startsWith('data-')).map(([k, v]) => `${k.slice(5)}="${v}"`).join(' ');
    // The canvas gives an import's host no style of its own: a placed component sits in a div that carries the placing.
    const imp = `<dc-import name="${boardOf(tag)}" ${props} hint-size="100%,40px"></dc-import>`;
    return a.style ? `<div style="${a.style}">${imp}</div>` : imp;
  });
}

function componentBoards() {
  const out = {};
  for (const c of COMPONENTS) {
    const Name = boardOf(c.tag);
    const first = attrsOf(c.states[0].inst.match(/<auburn-[a-z]+((?:\s+[a-z0-9-]+="[^"]*")*)/)[1]);
    const defaults = Object.fromEntries(Object.entries(first).filter(([k]) => k.startsWith('data-')).map(([k, v]) => [camel(k.slice(5)), v]));
    const props = {};
    for (const [k, values] of Object.entries(c.props)) {
      const range = values[0].match(/^(\d+)-(\d+|n)$/);
      props[camel(k)] = range ? { editor: 'range', default: Number(defaults[camel(k)] || 0), min: +range[1], max: range[2] === 'n' ? 20 : +range[2], step: 1, section: 'Properties' }
        : { editor: 'enum', options: values, default: defaults[camel(k)] || values[0], section: 'Properties' };
    }
    for (const k of c.text) props[camel(k)] = { editor: 'text', default: defaults[camel(k)] || '', section: 'Text' };
    const size = (id) => { const s = readFileSync(`${SPEC}/components/${c.name}/${id}.png`); return { width: s.readUInt32BE(16), height: s.readUInt32BE(20) }; };
    props.$preview = size(c.states[0].id);
    const template = bustToMask(c.html)
      .replace(/<template data-each="([a-z0-9]+)">([\s\S]*?)<\/template>/g, '<sc-for list="{{$1}}" as="item" hint-placeholder-count="3">$2</sc-for>');
    const root = `<div class="${c.tag}" ${Object.keys(c.props).map((k) => `data-${k}="{{${camel(k)}}}"`).join(' ')}>\n${toImports(template)}\n</div>`;
    const lists = [...c.html.matchAll(/<template data-each="([a-z0-9]+)">/g)].map((m) => m[1]);
    out[`${Name}.dc.html`] = board({
      title: `Component · ${c.name} · agreed`,
      fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
      helmet: '',
      body: root,
      script: `class Component extends DCLogic {
constructor(props) {
super(props);
// Ids inside the component, unique to this one.
var k = this.constructor;
this.uid = 'u' + (k.count = (k.count || 0) + 1);
}
renderVals() {
var p = this.props, defaults = ${JSON.stringify(defaults)}, d = { uid: this.uid };
Object.keys(defaults).forEach(function (k) { d[k] = p[k] != null ? p[k] : defaults[k]; });
${c.logic ? `Object.assign(d, (${c.logic})(d));\n` : ''}${JSON.stringify(lists)}.forEach(function (k) { if (typeof d[k] === 'string') d[k] = d[k] ? d[k].split('|') : []; });
return d;
}
}`,
      props,
    });
    // The states, each in its frame, as component.html lists them.
    const frames = c.states.map((s) => {
      const sz = size(s.id);
      return `<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 12px; font-weight: 700; letter-spacing: 1.5px; color: #8A8A8A; text-transform: uppercase">${s.label}</div>
<div style="position: relative; ${s.frame}; background: var(--color-ground); color: var(--color-accent); font-family: var(--font-interface)">${toImports(s.inst)}</div></div>`;
    }).join('\n');
    const w = 64 + c.states.reduce((a, s) => a + size(s.id).width + 40, -40);
    const h = 64 + 28 + Math.max(...c.states.map((s) => size(s.id).height));
    out[`${Name}-States.dc.html`] = board({
      title: `Component · ${c.name} · states`,
      fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
      body: `<div style="width: ${w}px; height: ${h}px; box-sizing: border-box; padding: 32px; background: #000; font-family: var(--font-interface); display: flex; gap: 40px; align-items: flex-start">\n${frames}\n</div>`,
      script: screenScript(''),
      props: { $preview: { width: w, height: h } },
    });
  }
  return out;
}

function navigationBoards(round) {
  const src = readFileSync(`${SPEC}/01-navigation/screen.html`, 'utf8');
  const names = { home: 'Home', raised: 'Raised', workout: 'Workout', editing: 'Editing', 'editing-full': 'Editing-Full', 'power-down': 'Power' };
  const titles = { home: 'home', raised: 'list raised', workout: 'workout in progress', editing: 'editing the Goals widget', 'editing-full': 'editing the Rest widget, full width', 'power-down': 'power down, held' };
  const out = {};
  const states = [...src.matchAll(/<section class="state" id="([a-z-]+)">\s*<h2>[^<]*<\/h2>\s*([\s\S]*?)<\/section>/g)].map((m) => [m[1], m[2].trim()]);
  // Round 3 also edits a full-width widget: the editing state, with Rest edited and the others stepped back.
  if (round) {
    const at = states.findIndex(([id]) => id === 'editing');
    const full = states[at][1].replace(/data-state="editing"/, 'data-state="stepped-back"')
      .replace(/(data-kind="rest" data-width="full" data-state=")stepped-back"/, '$1editing"');
    states.splice(at + 1, 0, ['editing-full', full]);
  }
  for (let [id, html] of states) {
    // The agreed screen imports the component boards; a round works on its own copy, flattened.
    html = round ? tapAreas(bustToMask(expand(html))).replace(/style="([^"]*)"/g, (_, st) => `style="${onScales(st)}"`) : toImports(html);
    // The screen's root takes whatever the Theme or round board passes in.
    html = html.replace(/^<div style="([^"]*)">/, (_, st) => `<div style="${st.replace(/;?\s*$/, '')}; {{theme}}">`);
    out[`S01-${round ? 'R3-' : ''}${names[id]}.dc.html`] = board({
      title: round ? `Round 3 · ${titles[id]} · on the scales · in progress` : `Navigation · ${titles[id]} · agreed`,
      fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
      helmet: '',
      body: html,
      script: screenScript(round ? vars([...roundTokens, ...swatchTokens]) : ''),
      props: { theme: { editor: null }, $preview: { width: 400, height: 640 } },
    });
  }
  return out;
}

// ---- boards with tweaks: the Theme board and round boards ----

function controlBoard({ file, seedFrom, title, heading, note, toks, rows, width, height }) {
  // The user's values on this board; a new board takes them from the board it replaces, if any.
  const kept = existsSync(`${OUT}/${file}`) ? readProps(`${OUT}/${file}`) : readProps(`${OUT}/${seedFrom}`);
  // Values kept under a name a basic or trial has since been given.
  for (const [was, now] of Object.entries(RENAMED)) if (kept[was] && !kept[now]) kept[now] = kept[was];
  const props = {};
  const tokens = toks;
  for (const t of tokens) {
    const k = keyOf(t);
    props[k] = { ...t.meta };
    // The user's value stays, unless it is no longer one of the choices.
    if (kept[k] && kept[k].default !== undefined && (!t.meta.options || t.meta.options.includes(kept[k].default))) props[k].default = kept[k].default;
  }
  props.$preview = { width, height };
  const list = tokens.map((t) => ({ k: keyOf(t), css: t.css, unit: t.unit, start: t.meta.default, trial: t.trial, ref: !!t.ref, light: !!t.light }));
  const imports = rows.map((r) => `<div style="display: flex; flex-direction: column; gap: 12px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px">${r.label}</div>
<div style="display: flex; gap: 40px; align-items: flex-start">
${r.boards.map((b) => `<dc-import name="${b.replace('.dc.html', '')}" theme="{{${/Light/.test(b) ? 'themeLight' : 'theme'}}}" hint-size="400px,640px"></dc-import>`).join('\n')}
</div>
</div>`).join('\n');
  const body = `<div style="width: ${width}px; height: ${height}px; box-sizing: border-box; padding: 32px; background: var(--obsidian); color: var(--cyan-white); font-family: var(--font-interface); font-size: 12px; letter-spacing: 1px; display: flex; gap: 48px">
<div style="width: 380px; flex: none; display: flex; flex-direction: column; gap: 16px; overflow: hidden">
<div style="font-size: 16px; font-weight: 700; letter-spacing: 2px">${heading}</div>
<div style="opacity: 0.7; line-height: 17px">${note} Tune every value in this board's Tweaks tab; a change stays on this board until it is persisted. Ctrl+Z steps back until the page is switched; the log below keeps every change since. Reset all: ask Claude.</div>
<button type="button" onPointerDown="{{holdOn}}" onPointerUp="{{holdOff}}" onPointerLeave="{{holdOff}}" onPointerCancel="{{holdOff}}" style="{{holdStyle}}">HOLD · PREVIEW START</button>
<div style="font-weight: 700">{{status}}</div>
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; margin-top: 8px">CHANGED · {{changedCount}}</div>
<sc-if value="{{noChanges}}" hint-placeholder-val="{{true}}"><div style="opacity: 0.55">Nothing changed from the start.</div></sc-if>
<sc-for list="{{changed}}" as="c" hint-placeholder-count="3"><div style="display: flex; gap: 8px"><span style="flex: 1; font-weight: 700">{{c.css}}</span><span style="opacity: 0.55">{{c.from}}</span><span>→ {{c.to}}</span></div></sc-for>
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; margin-top: 8px">TRIALS · NOT YET BASICS</div>
<div style="opacity: 0.7; line-height: 17px">{{trialNames}}</div>
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; margin-top: 8px">LOG · ON THIS COMPUTER</div>
<sc-if value="{{noLog}}" hint-placeholder-val="{{true}}"><div style="opacity: 0.55">No changes seen yet.</div></sc-if>
<sc-for list="{{log}}" as="e" hint-placeholder-count="3"><div style="display: flex; gap: 8px"><span style="opacity: 0.55">{{e.at}}</span><span style="flex: 1; font-weight: 700">{{e.css}}</span><span style="opacity: 0.55">{{e.from}}</span><span>→ {{e.to}}</span></div></sc-for>
</div>
<div style="display: flex; flex-direction: column; gap: 48px">
${imports}
</div>
</div>`;
  const script = `class Component extends DCLogic {
constructor(props) {
super(props);
// Every tweak: its CSS name, its unit, and its start (the basic, or the trial's first value).
this.tokens = ${JSON.stringify(list)};
var log = [];
try { log = JSON.parse(window.localStorage.getItem(${JSON.stringify(`auburn.log.${file}`)}) || '[]'); } catch (e) {}
this.state = { holding: false, log: log };
}
value(t, props) {
var v = props[t.k];
return v == null ? t.start : v;
}
// As CSS: a palette name becomes a reference to that colour.
show(t, v) {
return t.ref ? 'var(--' + v + ')' : String(v) + t.unit;
}
// As read on the board.
label(t, v) {
return t.ref ? String(v) : String(v) + t.unit;
}
// Every change the board sees is logged, newest first, and kept on this computer.
componentDidUpdate(prev) {
var self = this, added = [];
var now = new Date(), at = ('0' + now.getHours()).slice(-2) + ':' + ('0' + now.getMinutes()).slice(-2);
this.tokens.forEach(function (t) {
var a = self.label(t, self.value(t, prev), prev), b = self.label(t, self.value(t, self.props), self.props);
if (a !== b) added.push({ at: at, css: (t.light ? 'light ' : '') + t.css, from: a, to: b });
});
if (!added.length) return;
var log = added.concat(this.state.log).slice(0, 40);
try { window.localStorage.setItem(${JSON.stringify(`auburn.log.${file}`)}, JSON.stringify(log)); } catch (e) {}
this.setState({ log: log });
}
renderVals() {
var self = this, holding = this.state.holding, props = this.props;
// While held, the screens show the start and nothing is changed.
var css = function (t) { return t.css + ': ' + (holding ? self.show(t, t.start, null) : self.show(t, self.value(t, props), props)); };
// The light theme's values follow the dark ones, so they win on the screens shown in the light theme.
var theme = this.tokens.filter(function (t) { return !t.light; }).map(css).join('; ');
var themeLight = theme + '; ' + this.tokens.filter(function (t) { return t.light; }).map(css).join('; ');
var changed = this.tokens.map(function (t) { return { css: (t.light ? 'light ' : '') + t.css, from: self.label(t, t.start, null), to: self.label(t, self.value(t, props), props) }; })
.filter(function (c) { return c.from !== c.to; });
return {
theme: theme, themeLight: themeLight,
changed: changed, changedCount: changed.length, noChanges: changed.length === 0,
trialNames: this.tokens.filter(function (t) { return t.trial; }).map(function (t) { return t.css; }).join(' · '),
log: this.state.log.slice(0, 20), noLog: this.state.log.length === 0,
status: holding ? 'SHOWING THE START' : 'SHOWING YOUR VALUES',
holdOn: function () { self.setState({ holding: true }); },
holdOff: function () { if (self.state.holding) self.setState({ holding: false }); },
holdStyle: 'height: 44px; padding: 0 14px; font-family: inherit; font-size: 13px; font-weight: 700; letter-spacing: 1.5px; cursor: pointer; touch-action: none; user-select: none; border: 2px solid var(--cyan-white); background: ' + (holding ? 'var(--cyan-white)' : 'transparent') + '; color: ' + (holding ? 'var(--obsidian)' : 'var(--cyan-white)')
};
}
}`;
  return board({
    title,
    fonts: 'family=Gelasio:wght@700&amp;family=Saira:wght@300;600&amp;family=Courier+Prime:wght@400;700',
    body, script, props,
  });
}

// ---- write ----

const parts = componentBoards();
const boot = bootBoards();
const agreed = navigationBoards(false);
const round3 = navigationBoards(true);
const W = 2652;
// A row of n screens: the padding, the side column and its gap, then each screen and the gap after it.
const rowWidth = (n) => 452 + 440 * n;
const files = {
  ...parts, ...boot, ...agreed, ...round3,
  'Theme.dc.html': controlBoard({
    file: 'Theme.dc.html', title: 'Theme', heading: 'THEME', note: 'Every agreed screen.',
    toks: [...basicTokens, ...swatchTokens], width: W, height: 1456,
    rows: [
      { label: 'SCREEN 01 · NAVIGATION · AGREED', boards: Object.keys(agreed) },
      { label: 'SCREEN 00 · BOOT · AGREED', boards: Object.keys(boot) },
    ],
  }),
  'S01-R3-Round.dc.html': controlBoard({
    // Round 3 takes the values tuned while it sat on the old Basics page.
    file: 'S01-R3-Round.dc.html', seedFrom: 'Basics-Theme.dc.html', title: 'Round 3 · screen 01 · in progress', heading: 'ROUND 3 · SCREEN 01 · IN PROGRESS',
    note: 'Screen 01 on the type and spacing scales, with text colours.',
    toks: [...basicTokens, ...roundTokens, ...swatchTokens], width: rowWidth(Object.keys(round3).length), height: 760,
    rows: [{ label: 'SCREEN 01 · ROUND 3 · ON THE SCALES', boards: Object.keys(round3) }],
  }),
};
for (const [name, text] of Object.entries(files)) writeFileSync(`${OUT}/${name}`, text);
copyFileSync(`${SPEC}/basics.css`, `${OUT}/basics.css`);

// canvas.json: the Theme page first, an entry per board (a board already placed keeps its place), the order.
const index = JSON.parse(readFileSync(`${OUT}/canvas.json`, 'utf8'));
const themePage = index.pages.find((p) => p.id === 'basics');
if (themePage) themePage.name = 'Theme'; else index.pages.unshift({ id: 'basics', name: 'Theme' });
if (!index.pages.some((p) => p.id === 'components')) index.pages.splice(index.pages.findIndex((p) => p.id === 'basics') + 1, 0, { id: 'components', name: 'Components' });
index.launch = { view: 'canvas', page: 'basics' };
for (const gone of ['Basics-Theme.dc.html']) { delete index.boards[gone]; index.order = index.order.filter((o) => o !== gone); }
const place = (name, entry) => {
  index.boards[name] = { ...entry, ...(index.boards[name] ? { x: index.boards[name].x, y: index.boards[name].y } : {}) };
  if (!index.order.includes(name)) index.order.push(name);
};
const label = (n) => n.replace(/^S01-(R3-)?/, '').replace('.dc.html', '').toLowerCase();
place('Theme.dc.html', { page: 'basics', title: 'Theme · tune in the Tweaks tab', w: W, h: 1456, x: 0, y: 0, is_interactive: true });
place('S01-R3-Round.dc.html', { page: 's01', title: 'Round 3 · in progress · tune in the Tweaks tab', w: rowWidth(Object.keys(round3).length), h: 760, x: 0, y: 11480, is_interactive: true });
Object.keys(round3).forEach((n, i) => place(n, { page: 's01', title: `Round 3 · ${label(n)} · on the scales · in progress`, w: 400, h: 640, x: i * 480, y: 10560 }));
Object.keys(agreed).forEach((n, i) => place(n, { page: 's01', title: `Navigation · ${label(n)} · agreed`, w: 400, h: 640, x: i * 480, y: 12620 }));
// Components: each one's states board, then the component's own board beside it.
let y = 0;
for (const c of COMPONENTS) {
  const s = parts[`${boardOf(c.tag)}-States.dc.html`].match(/"\$preview":\{"width":(\d+),"height":(\d+)\}/);
  const p = parts[`${boardOf(c.tag)}.dc.html`].match(/"\$preview":\{"width":(\d+),"height":(\d+)\}/);
  place(`${boardOf(c.tag)}-States.dc.html`, { page: 'components', title: `${cap(c.name)} · states · agreed`, w: +s[1], h: +s[2], x: 0, y });
  place(`${boardOf(c.tag)}.dc.html`, { page: 'components', title: `${cap(c.name)} · the component · tune its properties in the Tweaks tab`, w: +p[1], h: +p[2], x: +s[1] + 80, y, is_interactive: true });
  y += Math.max(+s[2], +p[2]) + 120;
}
index.notes.components = index.notes.components || { kind: 'title1', maxW: 2400, page: 'components', text: 'Components — agreed', w: 240, x: 0, y: -300 };
Object.keys(boot).forEach((n, i) => place(n, { page: 's00', title: `Boot · ${i ? 'light' : 'dark'} · agreed`, w: 400, h: 640, x: i * 480, y: 7460 }));
delete index.notes.basics;
index.notes.theme = index.notes.theme || { kind: 'title1', maxW: W, page: 'basics', text: 'Theme — every agreed screen, tuned at once', w: 240, x: 0, y: -300 };
index.notes.s01r3 = index.notes.s01r3 || { kind: 'title1', maxW: 2320, page: 's01', text: 'Round 3 — screen 01 on the type and spacing scales', w: 240, x: 0, y: 10280 };
index.notes.s01r3board = index.notes.s01r3board || { kind: 'title1', maxW: W, page: 's01', text: 'Round 3 — tune here; changes stay on this board', w: 240, x: 0, y: 11200 };
index.notes.s01agreed = index.notes.s01agreed || { kind: 'title1', maxW: 2320, page: 's01', text: 'Screen 01 — agreed', w: 240, x: 0, y: 12340 };
index.notes.s00agreed = index.notes.s00agreed || { kind: 'title1', maxW: 880, page: 's00', text: 'Boot · agreed', w: 240, x: 0, y: 7180 };
writeFileSync(`${OUT}/canvas.json`, `${JSON.stringify(index, null, 2)}\n`);

console.log('Built:', Object.keys(files).join(', '), '+ basics.css, canvas.json');
if (Object.keys(leftovers).length) console.log('Left off the spacing scale:', leftovers);
