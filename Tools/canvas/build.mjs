// Builds the canvas boards that are generated rather than drawn, into the mirror at Canvas/project/.
//
//   Basics-Theme.dc.html     the Theme board: a tweak for every basic except the tube's, and for every trial below;
//                            the changed list, hold-to-preview, the change log, and every screen it shows.
//   S00-Dark, S00-Light      the agreed boot (Spec/Visual Design/00-boot/screen.html), held frame, line 0.
//   S01-R3-<state>           screen 01, round 3: the agreed screen (Spec/Visual Design/01-navigation/screen.html)
//                            moved onto the trial type and spacing scales.
//   basics.css               a copy of Spec/Visual Design/basics.css.
//
// Values the user has set in the Theme board's Tweaks tab are read from the mirror and kept.
// It also updates Canvas/project/canvas.json: the Basics page, each board's entry (a board the user moved keeps
// its place), and the order. Run from the repository root: node Tools/canvas/build.mjs
// Then commit and publish the changed files as CLAUDE.md's The canvas says.

import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'node:fs';

const SPEC = 'Spec/Visual Design';
const OUT = 'Canvas/project';
const BUST = '/_blob/8dc69cd32a565ee54c5606a82fce2b14'; // the traced bust, uploaded to the canvas

// Trials: values the canvas is trying that are not basics yet. Each is listed on the boards that use it.
const TRIALS = [
  ['Type scale', [
    ['--text-1', '11px'], ['--text-1-tracking', '0.5px'], ['--text-1-leading', '15px'],
    ['--text-2', '13px'], ['--text-2-tracking', '2px'], ['--text-2-leading', '11px'],
    ['--text-3', '16px'], ['--text-3-tracking', '1.5px'], ['--text-3-leading', '20px'],
    ['--text-4', '22px'], ['--text-4-tracking', '6px'], ['--text-4-leading', '24px'],
  ]],
  // Each emphasis level's text takes its colour from the palette, by name; its opacity stays the level's.
  ['Text colour', [
    ['--primary-text-color', 'var(--ember)'], ['--secondary-text-color', 'var(--ember)'], ['--supporting-text-color', 'var(--ember)'],
  ]],
  ['Spacing scale', [
    ['--space-1', '2px'], ['--space-2', '4px'], ['--space-3', '8px'],
    ['--space-4', '12px'], ['--space-5', '16px'], ['--space-6', '24px'],
  ]],
];

// Screen 01's sizes, as they were before the scales, and the step each moves to.
const TEXT_STEP = { 10: 1, 11: 1, 13: 2, 16: 3, 22: 4 };
const SPACE_STEP = { 2: 1, 4: 2, 6: 3, 7: 3, 8: 3, 10: 4, 12: 4, 16: 5, 18: 5, 24: 6 };

// ---- basics.css ----

function parseBasics(path) {
  const groups = [];
  let group = null;
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const g = line.match(/^\s*\/\*\s*([A-Z][^(*]*?)\s*(\(.*)?\*\/\s*$/);
    if (g) { group = { name: g[1].split(':')[0].trim(), tokens: [] }; groups.push(group); continue; }
    for (const m of line.matchAll(/(--[a-z0-9-]+):\s*([^;]+);/g)) group.tokens.push([m[1], m[2].trim()]);
  }
  return groups;
}

const key = (css) => css.slice(2).replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());

// A token's Tweaks editor, its value as the editor holds it, and how that value is written back as CSS.
function editorFor(css, value, section) {
  const ref = value.match(/^var\(--([a-z-]+)\)$/);
  if (ref) return { meta: { editor: 'enum', options: PALETTE, default: ref[1], section }, unit: '', ref: true };
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
const PALETTE = basics.find((g) => g.name === 'Palette').tokens.map(([css]) => css.slice(2));
const tokens = [];
for (const g of basics) for (const [css, v] of g.tokens) tokens.push({ css, start: v, trial: false, ...editorFor(css, v, g.name) });
for (const [name, list] of TRIALS) for (const [css, v] of list) tokens.push({ css, start: v, trial: true, ...editorFor(css, v, `${name} · trial`) });

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

const trialVars = tokens.filter((t) => t.trial).map((t) => `${t.css}: ${t.start}`).join('; ');

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
      body: `<div class="b00 b00-${theme} b00-screen" style="{{theme}}">${markup}</div>`,
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
  const lvl = s.match(/color: color-mix\(in srgb, var\(--ember\) var\(--(primary|secondary|supporting)-text\)/);
  if (lvl) s = s.replace(/font-weight: \d+/, `font-weight: var(--${lvl[1]}-text-weight)`);
  // Text takes its level's colour.
  s = s.replace(/var\(--ember\) var\(--(primary|secondary|supporting)-text\)/g, 'var(--$1-text-color) var(--$1-text)');
  // Lines take their level's width.
  s = s.replace(/(border(?:-top|-bottom|-left|-right)?): \d+px solid (color-mix\(in srgb, var\(--ember\) var\(--(primary|secondary|supporting)-line\))/g,
    (_, p, mix, l) => `${p}: var(--${l}-line-width) solid ${mix}`);
  // Gaps, padding and margins take steps of the spacing scale; negative margins stay as they are.
  s = s.replace(/\b((?:row-|column-)?gap|padding(?:-[a-z]+)?|margin(?:-[a-z]+)?): ([^;"]+)/g, (all, p, v) => {
    if (/-\d/.test(v)) return all;
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

function navigationBoards() {
  const src = readFileSync(`${SPEC}/01-navigation/screen.html`, 'utf8');
  const roles = src.match(/:root\s*\{([^}]*)\}/)[1].replace(/\/\*[\s\S]*?\*\//g, '').split('\n').map((l) => l.trim()).filter(Boolean).join(' ');
  const names = { home: 'Home', raised: 'Raised', workout: 'Workout', editing: 'Editing', 'power-down': 'Power' };
  const titles = { home: 'home', raised: 'list raised', workout: 'workout in progress', editing: 'editing the Goals widget', 'power-down': 'power down, held' };
  const out = {};
  for (const m of src.matchAll(/<section class="state" id="([a-z-]+)">\s*<h2>[^<]*<\/h2>\s*([\s\S]*?)<\/section>/g)) {
    let html = m[2].trim()
      .replace(/<img class="bust" src="[^"]*" alt="" style="([^"]*)">/g, '<div class="bust" aria-hidden="true" style="$1"></div>')
      .replace(/style="([^"]*)"/g, (_, st) => `style="${onScales(st)}"`);
    // The screen's root: its roles, then whatever the Theme board passes in.
    html = html.replace(/^<div style="([^"]*)">/, (_, st) => `<div style="${st.replace(/;?\s*$/, '')}; ${roles} {{theme}}">`);
    out[`S01-R3-${names[m[1]]}.dc.html`] = board({
      title: `Round 3 · ${titles[m[1]]} · on the scales`,
      fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
      helmet: `@keyframes blink{0%,49%{opacity:1}50%,100%{opacity:0}}\n.bust{background: var(--ember); -webkit-mask: url(${BUST}) center top / contain no-repeat; mask: url(${BUST}) center top / contain no-repeat}\na{color:inherit}`,
      body: html,
      script: screenScript(trialVars),
      props: { theme: { editor: null }, $preview: { width: 400, height: 640 } },
    });
  }
  return out;
}

// ---- the Theme board ----

function themeBoard(rows) {
  const kept = readProps(`${OUT}/Basics-Theme.dc.html`);
  const props = {};
  for (const t of tokens) {
    const k = key(t.css);
    props[k] = { ...t.meta };
    if (kept[k] && kept[k].default !== undefined) props[k].default = kept[k].default; // the user's value stays
  }
  props.$preview = { width: 2652, height: 1456 };
  const list = tokens.map((t) => ({ k: key(t.css), css: t.css, unit: t.unit, start: t.meta.default, trial: t.trial, ref: !!t.ref }));
  const imports = rows.map((r) => `<div style="display: flex; flex-direction: column; gap: 12px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px">${r.label}</div>
<div style="display: flex; gap: 40px; align-items: flex-start">
${r.boards.map((b) => `<dc-import name="${b.replace('.dc.html', '')}" theme="{{theme}}" hint-size="400px,640px"></dc-import>`).join('\n')}
</div>
</div>`).join('\n');
  const body = `<div style="width: 2652px; height: 1456px; box-sizing: border-box; padding: 32px; background: var(--obsidian); color: var(--cyan-white); font-family: var(--font-interface); font-size: 12px; letter-spacing: 1px; display: flex; gap: 48px">
<div style="width: 380px; flex: none; display: flex; flex-direction: column; gap: 16px; overflow: hidden">
<div style="font-size: 16px; font-weight: 700; letter-spacing: 2px">THEME</div>
<div style="opacity: 0.7; line-height: 17px">Tune every value in this board's Tweaks tab. Ctrl+Z steps back until the page is switched; the log below keeps every change since. Reset all: ask Claude.</div>
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
try { log = JSON.parse(window.localStorage.getItem('auburn.theme.log') || '[]'); } catch (e) {}
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
var a = self.value(t, prev), b = self.value(t, self.props);
if (String(a) !== String(b)) added.push({ at: at, css: t.css, from: self.label(t, a), to: self.label(t, b) });
});
if (!added.length) return;
var log = added.concat(this.state.log).slice(0, 40);
try { window.localStorage.setItem('auburn.theme.log', JSON.stringify(log)); } catch (e) {}
this.setState({ log: log });
}
renderVals() {
var self = this, holding = this.state.holding, props = this.props;
// While held, the screens show the start and nothing is changed.
var theme = this.tokens.map(function (t) { return t.css + ': ' + self.show(t, holding ? t.start : self.value(t, props)); }).join('; ');
var changed = this.tokens.filter(function (t) { return String(self.value(t, props)) !== String(t.start); })
.map(function (t) { return { css: t.css, from: self.label(t, t.start), to: self.label(t, self.value(t, props)) }; });
return {
theme: theme,
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
    title: 'Theme',
    fonts: 'family=Gelasio:wght@700&amp;family=Saira:wght@300;600&amp;family=Courier+Prime:wght@400;700',
    body, script, props,
  });
}

// ---- write ----

const boot = bootBoards();
const nav = navigationBoards();
const rows = [
  { label: 'SCREEN 01 · ROUND 3 · ON THE SCALES', boards: Object.keys(nav) },
  { label: 'SCREEN 00 · BOOT · AGREED', boards: Object.keys(boot) },
];
const files = { ...nav, ...boot, 'Basics-Theme.dc.html': themeBoard(rows) };
for (const [name, text] of Object.entries(files)) writeFileSync(`${OUT}/${name}`, text);
copyFileSync(`${SPEC}/basics.css`, `${OUT}/basics.css`);

// canvas.json: the Basics page first, an entry per board (a board already placed keeps its place), the order.
const index = JSON.parse(readFileSync(`${OUT}/canvas.json`, 'utf8'));
if (!index.pages.some((p) => p.id === 'basics')) index.pages.unshift({ id: 'basics', name: 'Basics' });
index.launch = { view: 'canvas', page: 'basics' };
const place = (name, entry) => {
  index.boards[name] = { ...entry, ...(index.boards[name] ? { x: index.boards[name].x, y: index.boards[name].y } : {}) };
  if (!index.order.includes(name)) index.order.push(name);
};
place('Basics-Theme.dc.html', { page: 'basics', title: 'Theme · tune in the Tweaks tab', w: 2652, h: 1456, x: 0, y: 0, is_interactive: true });
Object.keys(nav).forEach((n, i) => place(n, { page: 's01', title: `Round 3 · ${n.replace('S01-R3-', '').replace('.dc.html', '').toLowerCase()} · on the scales`, w: 400, h: 640, x: i * 480, y: 10560 }));
Object.keys(boot).forEach((n, i) => place(n, { page: 's00', title: `Boot · ${i ? 'light' : 'dark'} · agreed`, w: 400, h: 640, x: i * 480, y: 7460 }));
index.notes.basics = index.notes.basics || { kind: 'title1', maxW: 2652, page: 'basics', text: 'Basics — the theme, tuned on every screen at once', w: 240, x: 0, y: -300 };
index.notes.s01r3 = index.notes.s01r3 || { kind: 'title1', maxW: 2320, page: 's01', text: 'Round 3 — screen 01 on the type and spacing scales', w: 240, x: 0, y: 10280 };
index.notes.s00agreed = index.notes.s00agreed || { kind: 'title1', maxW: 880, page: 's00', text: 'Boot · agreed', w: 240, x: 0, y: 7180 };
writeFileSync(`${OUT}/canvas.json`, `${JSON.stringify(index, null, 2)}\n`);

console.log('Built:', Object.keys(files).join(', '), '+ basics.css, canvas.json');
if (Object.keys(leftovers).length) console.log('Left off the spacing scale:', leftovers);
