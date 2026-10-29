// Builds the canvas boards that are generated rather than drawn, into the mirror at Canvas/project/.
//
//   Theme.dc.html            the Theme board: every agreed screen, a tweak for every basic except the tube's,
//                            and the swatches; the changed list, hold-to-preview and the change log.
//   C-<Name>, C-<Name>-States each agreed component (Lens/Language/Visual/components/<name>/component.html), with a
//                            tweak for each property, and a board showing its states.
//   S01-R3-Round.dc.html     screen 01's round 3 board: the same, for round 3's states, plus the trials below.
//   S00-Dark, S00-Light      the agreed boot (Spec/Screens/00-boot/screen.html), held frame, line 0.
//   S01-<state>              the agreed screen 01 (Spec/Screens/01-navigation/screen.html), importing the
//                            component boards.
//   C-R3-<Name>, -States     each component's round for screen 01's round 3, from its template in
//                            Tools/canvas/rounds/r3/<name>/. C-R3-Screens shows round 3's screens.
//   S01-R3-<state>           screen 01, round 3: the agreed screen importing the component rounds, its own placing
//                            on the scales, with no editing state.
//   X-Palette.dc.html        the palette exploration: a ramp per role with contrast, and round 3's home under three
//                            ways of colouring text. Its colours come from palette.mjs.
//   X-Colour-Grid.dc.html    the colour grid exploration: palette primitives the user names in its Tweaks tab, each a
//                            ramp centred on it; a grid of kinds by levels picking steps from them; and round 3's home,
//                            each of its parts taking a cell and a weight.
//   basics.css               a copy of Lens/Language/basics.css.
//
// Values the user has set in a board's Tweaks tab are read from the mirror and kept. A change stays on its board.
// It also updates Canvas/project/canvas.json: the Theme page, each board's entry (a board the user moved keeps
// its place), and the order. Run from the repository root: node Tools/canvas/build.mjs
// Then commit and publish the changed files as CLAUDE.md's The canvas says.

import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'node:fs';
import { components, readComponent } from '../build-components.mjs';
import { rampAround, contrast, over, oklch, COLOUR_JS } from './palette.mjs';

const SCREENS = 'Spec/Screens';
const VISUAL = 'Lens/Language/Visual';
const BASICS = 'Lens/Language/basics.css';
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
  // Primary and supporting text take their colour from the palette or a swatch, by name; the opacity stays the level's.
  ['Text colour', [
    ['--color-primary-text', 'var(--ember)'], ['--color-supporting-text', 'var(--ember)'],
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

const basics = parseBasics(BASICS).filter((g) => !/tube/i.test(g.name));
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
/* The phone's browser may enlarge text on a page it thinks is not built for it; the boards show text at its own size. */
html, body{-webkit-text-size-adjust:100%; text-size-adjust:100%}
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
  const src = readFileSync(`${SCREENS}/00-boot/screen.html`, 'utf8');
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
  // The boot shows one of its lines; the line the user set on the board stays, if it is still one of them.
  const listed = src.match(/var lines = (\[[^\]]*\]);/);
  const lines = listed ? JSON.parse(listed[1].replace(/'/g, '"')) : [];
  const shown = existsSync(`${OUT}/S00-Dark.dc.html`) && (readFileSync(`${OUT}/S00-Dark.dc.html`, 'utf8').match(/<div class="b00-line"><span>([^<]*)<\/span>/) || [])[1];
  const shownLine = lines.includes(shown) ? shown : lines[0];
  const markup = src.match(/<div class="screen">([\s\S]*?)<\/div>\s*<script>/)[1]
    .replace(/<div class="power-line"[^>]*><\/div>/, '')
    .replace(/class="([a-z-]+)"/g, (_, c) => `class="${c.split(' ').map((x) => `b00-${x}`).join(' ')}"`)
    .replace('<span id="line"></span>', `<span>${shownLine}</span>`);
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

// Round 3's screen, before its components are filled in, with its gaps from the spacing table. The list sits lower
// than the agreed screen's by its three entries' growth, so the same three show. The header is a section of its own;
// the wordmark's top is measured to its letters.
const roundScreen = (html) => html
  .replace(/top: 432px/g, 'top: calc(432px - 3 * (var(--tap-area) - 42px))')
  .replace(/top: 18px; display: flex; flex-direction: column; gap: 10px/g,
    'top: calc(var(--space-5) - (var(--text-4-leading) - var(--text-4)) / 2); display: flex; flex-direction: column; gap: var(--space-6)')
  .replace(/(grid-template-columns: repeat\(2, minmax\(0, 1fr\)\); gap: 8px); margin-top: 4px/g, '$1');

// ---- components ----

const COMPONENTS = components();
// Round 3's copy of each component is its own template, Tools/canvas/rounds/r3/<name>/component.html: on the scales,
// with its gaps from the visual language's spacing table. Approving the round makes it the agreed component.html.
const roundFile = (name) => `Tools/canvas/rounds/r3/${name}/component.html`;
const ROUND = COMPONENTS.map((c) => ({ name: c.name, ...readComponent(roundFile(c.name)) }));
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);
// A component's board, or its round 3 copy's.
const boardOf = (tag, round) => `C-${round ? 'R3-' : ''}${cap(tag.replace('auburn-', ''))}`;
const camel = (s) => s.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
const attrsOf = (s) => Object.fromEntries([...s.matchAll(/([a-z0-9-]+)="([^"]*)"/g)].map(([, k, v]) => [k, v]));
const ROUND_CSS = ROUND.map((c) => c.css.replace(/\.(auburn-[a-z]+)\b/g, '.$1.round-3')).filter(Boolean).join('\n')
  // The hold key's letters take their colour from a rule, so its part's colour goes there.
  .replace(/(\.auburn-hold\.round-3 \.hold-letter\[data-state="idle"\] \{ color: )([^;]+);/, '$1var(--part-label-color, $2);');
const ALL_CSS = [...COMPONENTS.map((c) => c.css), ROUND_CSS].filter(Boolean).join('\n');
// Every board carries every component's rules: a board shown inside another takes only the outer board's rules.
// An import's host takes the part of the component's own element: out of the layout, or filling its placing.
const CONTENTS = COMPONENTS.filter((c) => /display: contents/.test(c.css)).map((c) => `.sc-host:has(> .${c.tag})`).join(', ');
const FILLED = COMPONENTS.filter((c) => !/display: contents/.test(c.css)).map((c) => `.sc-host:has(> .${c.tag}), .sc-host > .${c.tag}`).join(', ');
// A component's own board, shown alone, stands on the screen's ground as it would on a screen.
const ALONE = '#dc-root > .sc-host:has(> [class^="auburn-"]) { background: var(--color-ground); color: var(--color-accent); font-family: var(--font-interface); overflow: hidden; }';
// A round's copy shown on its own takes the round's trials at their start; inside a round's screen, the round board's.
const ALONE_ROUND = `#dc-root > .sc-host:has(> .round-3) { ${vars(roundTokens)} }`;
COMPONENT_CSS = `${ALL_CSS}\n${MASK_CSS}\na{color:inherit}\n${CONTENTS} { display: contents; }\n${FILLED} { height: 100%; }\n${ALONE}\n${ALONE_ROUND}`;
const bustToMask = (html) => html.replace(/<img alt="" class="bust" src="[^"]*" style="([^"]*)"\/?>/g, '<div class="bust" aria-hidden="true" style="$1"></div>');

// Parts: each piece of text in round 3's components carries data-part, naming it within its component. On the
// canvas, a part's colour and weight read --part-<name>-color and --part-<name>-weight before the level's own, and
// each placed instance passes its own --<instance>-<name>-color and -weight through to them. Nothing sets those but
// the colour grid, so every other board shows the level's values.
const PART_PROP = { name: 'background' }; // the name band is coloured by its ground; its letters stay ink
function withParts(html) {
  return html.replace(/<([a-z]+) data-part="([a-z0-9-]+)"([^>]*)>/g, (all, tag, part, rest) => {
    const prop = PART_PROP[part] || 'color';
    return `<${tag} data-part="${part}"${rest.replace(/style="([^"]*)"/, (_, st) => `style="${st
      .replace(new RegExp(`(^|;\\s*)${prop}: ([^;]+)`), (m, pre, v) => `${pre}${prop}: var(--part-${part}-color, ${v})`)
      .replace(/(^|;\s*)font-weight: ([^;]+)/, (m, pre, v) => `${pre}font-weight: var(--part-${part}-weight, ${v})`)}"`)}>`;
  });
}
// The parts each component holds, and the name each placed instance passes its values under.
const PARTS_OF = { 'auburn-header': ['wordmark', 'status'], 'auburn-widget': ['name', 'line-1', 'line-2'], 'auburn-list': ['handle'], 'auburn-hold': ['label'], 'auburn-entry': ['label'] };
const INSTANCE = { 'auburn-header': () => 'header', 'auburn-widget': (a) => a['data-kind'], 'auburn-list': () => 'list', 'auburn-hold': () => 'power' };
const partVars = (inst, parts) => parts.map((p) => `--part-${p}-color: var(--${inst}-${p}-color); --part-${p}-weight: var(--${inst}-${p}-weight)`).join('; ');

const onScalesAll = (html) => html.replace(/style="([^"]*)"/g, (_, st) => `style="${onScales(st)}"`);

// An element placing a component becomes an import of its board, or of its round 3 copy's; its data attributes
// become the board's props.
function toImports(html, round) {
  return html.replace(/<(auburn-[a-z]+)((?:\s+[a-z0-9-]+="[^"]*")*)\s*><\/\1>/g, (_, tag, attrs) => {
    const a = attrsOf(attrs);
    const props = Object.entries(a).filter(([k]) => k.startsWith('data-')).map(([k, v]) => `${k.slice(5)}="${v}"`).join(' ');
    // The canvas gives an import's host no style of its own: a placed component sits in a div that carries the placing.
    const imp = `<dc-import name="${boardOf(tag, round)}" ${props} hint-size="100%,40px"></dc-import>`;
    const parts = round && INSTANCE[tag] ? partVars(INSTANCE[tag](a), PARTS_OF[tag]) : '';
    if (a.style) return `<div style="${a.style}${parts ? `; ${parts}` : ''}">${imp}</div>`;
    return parts ? `<div style="display: contents; ${parts}">${imp}</div>` : imp;
  });
}

// Each component's board and states board; with round, its round 3 copy: on the scales, with its tap areas.
function componentBoards(round) {
  const out = {};
  for (const agreed of COMPONENTS) {
    const c = round ? ROUND.find((r) => r.name === agreed.name) : agreed;
    const Name = boardOf(c.tag, round);
    const first = attrsOf(c.states[0].inst.match(/<auburn-[a-z]+((?:\s+[a-z0-9-]+="[^"]*")*)/)[1]);
    const defaults = Object.fromEntries(Object.entries(first).filter(([k]) => k.startsWith('data-')).map(([k, v]) => [camel(k.slice(5)), v]));
    const props = {};
    const states = c.states;
    for (const [k, values] of Object.entries(c.props)) {
      const range = values[0].match(/^(\d+)-(\d+|n)$/);
      props[camel(k)] = range ? { editor: 'range', default: Number(defaults[camel(k)] || 0), min: +range[1], max: range[2] === 'n' ? 20 : +range[2], step: 1, section: 'Properties' }
        : { editor: 'enum', options: values, default: defaults[camel(k)] || values[0], section: 'Properties' };
    }
    for (const k of c.text) props[camel(k)] = { editor: 'text', default: defaults[camel(k)] || '', section: 'Text' };
    // The user's values on this board stay, unless one is no longer among the choices.
    const kept = readProps(`${OUT}/${Name}.dc.html`);
    for (const [k, meta] of Object.entries(props)) {
      if (kept[k] && kept[k].default !== undefined && (!meta.options || meta.options.includes(kept[k].default))) meta.default = kept[k].default;
    }
    // The agreed images' sizes; a round's copy grows, so its boards take room to spare.
    const grow = round ? 60 : 0;
    // A state with no image yet takes its frame's width and room to spare.
    const size = (id) => {
      const png = `${VISUAL}/components/${c.name}/${id}.png`;
      if (!existsSync(png)) return { width: +states.find((s) => s.id === id).frame.match(/width: (\d+)px/)[1], height: 200 };
      const s = readFileSync(png); return { width: s.readUInt32BE(16), height: s.readUInt32BE(20) + grow };
    };
    props.$preview = size(states[0].id);
    const template = bustToMask(round ? withParts(c.html) : c.html)
      .replace(/<template data-each="([a-z0-9]+)">([\s\S]*?)<\/template>/g, '<sc-for list="{{$1}}" as="item" hint-placeholder-count="3">$2</sc-for>');
    let inner = toImports(template, round);
    if (round) inner = inner.replace(/(<sc-for [^>]*>)(<dc-import name="C-R3-Entry"[^>]*><\/dc-import>)/g, (_, f, imp) => `${f}<div style="display: contents; ${partVars('entry-{{$index}}', PARTS_OF['auburn-entry'])}">${imp}</div>`);
    const root = `<div class="${c.tag}${round ? ' round-3' : ''}" ${Object.keys(c.props).map((k) => `data-${k}="{{${camel(k)}}}"`).join(' ')}>\n${inner}\n</div>`;
    const lists = [...c.html.matchAll(/<template data-each="([a-z0-9]+)">/g)].map((m) => m[1]);
    out[`${Name}.dc.html`] = board({
      title: round ? `Component round · ${c.name} · for screen 01's round 3 · in progress` : `Component · ${c.name} · agreed`,
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
    const frames = states.map((s) => {
      // A round's list frame grows with its entries.
      const entries = (s.inst.match(/data-entries="([^"]*)"/) || [, ''])[1].split('|').filter(Boolean).length;
      const frame = round && entries ? s.frame.replace(/height: (\d+)px/, `height: calc($1px + ${entries} * (var(--tap-area) - 42px))`) : s.frame;
      return `<div style="display: flex; flex-direction: column; gap: 8px"><div style="font-size: 12px; font-weight: 700; letter-spacing: 1.5px; color: #8A8A8A; text-transform: uppercase">${s.label}</div>
<div style="position: relative; ${frame}; background: var(--color-ground); color: var(--color-accent); font-family: var(--font-interface)">${toImports(s.inst, round)}</div></div>`;
    }).join('\n');
    const w = 64 + states.reduce((a, s) => a + size(s.id).width + 40, -40);
    const h = 64 + 28 + Math.max(...states.map((s) => size(s.id).height));
    out[`${Name}-States.dc.html`] = board({
      title: round ? `Component round · ${c.name} · states · in progress` : `Component · ${c.name} · states`,
      fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
      body: `<div style="width: ${w}px; height: ${h}px; box-sizing: border-box; padding: 32px; background: #000; font-family: var(--font-interface); display: flex; gap: 40px; align-items: flex-start${round ? `; ${vars(roundTokens)}` : ''}">\n${frames}\n</div>`,
      script: screenScript(''),
      props: { $preview: { width: w, height: h } },
    });
  }
  return out;
}

function navigationBoards(round) {
  const src = readFileSync(`${SCREENS}/01-navigation/screen.html`, 'utf8');
  const names = { home: 'Home', raised: 'Raised', workout: 'Workout', editing: 'Editing', 'power-down': 'Power' };
  const titles = { home: 'home', raised: 'list raised', workout: 'workout in progress', editing: 'editing the Goals widget', 'power-down': 'power down, held' };
  const out = {};
  // Round 3 has no editing state: home carries no EDIT, and the layout is edited in Settings.
  const states = [...src.matchAll(/<section class="state" id="([a-z-]+)">\s*<h2>[^<]*<\/h2>\s*([\s\S]*?)<\/section>/g)]
    .map((m) => [m[1], m[2].trim()]).filter(([id]) => !(round && id === 'editing'));
  for (let [id, html] of states) {
    // The agreed screen imports the agreed components; round 3 imports their round copies, and puts its own
    // placing on the scales.
    html = round ? onScalesAll(toImports(roundScreen(html), true)) : toImports(html);
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

const parts = componentBoards(false);
const partsRound = componentBoards(true);
const boot = bootBoards();
const agreed = navigationBoards(false);
const round3 = navigationBoards(true);
const W = 2652;
// A row of n screens: the padding, the side column and its gap, then each screen and the gap after it.
const rowWidth = (n) => 452 + 440 * n;
// ---- the palette exploration: ramps by role, and round 3's home under three ways of colouring text ----

const GROUND = '#1A1D1A', RAISED = '#212220';
const STEPS = [0.92, 0.82, 0.72, 0.62, 0.52, 0.42, 0.32];
// Each ramp is built around its colour, which stands in it exactly, in place of the nearest step.
const ROLES = [
  { name: 'ACCENT', note: 'Ember: marks, names, keys, lines', anchor: '#D9573B', label: 'EMBER' },
  { name: 'INFORMATION', note: 'A quiet neutral, around the pale green trial: data and body text', anchor: '#DFFFE4', label: 'TRIAL A' },
  { name: 'SET APART', note: 'Cyan white: only what must stand apart', anchor: '#DDF7F5', label: 'CYAN WHITE' },
].map((r) => ({ ...r, steps: rampAround(r.anchor, STEPS) }));
const step = (role, L) => ROLES.find((r) => r.name === role).steps.reduce((a, b) => (Math.abs(b.L - L) < Math.abs(a.L - L) ? b : a)).hex;
const fmt = (n) => n.toFixed(1);
const verdict = (c) => (c >= 4.5 ? 'TEXT' : c >= 3 ? 'LARGE' : '—');

function card(hexValue, label, sample) {
  const g = contrast(hexValue, GROUND), r = contrast(hexValue, RAISED);
  return `<div style="width: 150px; display: flex; flex-direction: column; gap: 6px; font-size: 11px; letter-spacing: 1px">
<div style="height: 44px; background: ${hexValue}"></div>
<div style="background: ${GROUND}; padding: 8px; color: ${hexValue}; font-size: 11px; font-weight: 700; letter-spacing: 0.5px; white-space: nowrap; overflow: hidden">${sample}</div>
<div style="color: #E8E8E8; font-weight: 700">${label}</div>
<div style="color: #9A9A9A">${hexValue}</div>
<div style="color: #9A9A9A">ON GROUND ${fmt(g)} · ${verdict(g)}</div>
<div style="color: #9A9A9A">ON LIST ${fmt(r)} · ${verdict(r)}</div>
</div>`;
}

function paletteBoard() {
  const rows = ROLES.map((r) => `<div style="display: flex; flex-direction: column; gap: 10px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; color: #E8E8E8">${r.name} · HUE ${Math.round(r.steps[0].H)} · <span style="color: #9A9A9A; font-weight: 400; letter-spacing: 1px">${r.note}</span></div>
<div style="display: flex; gap: 16px">${r.steps.map((s) => card(s.hex, `${s.anchor ? `${r.label} · ` : ''}L ${s.L.toFixed(2)} · C ${s.C.toFixed(3)}`, 'LAST RUN · 8.2 KM')).join('')}</div>
</div>`).join('\n');
  const opacity = `<div style="display: flex; flex-direction: column; gap: 10px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; color: #E8E8E8">EMBER BY OPACITY · <span style="color: #9A9A9A; font-weight: 400; letter-spacing: 1px">what the levels do now: each one mixed toward the ground beneath it</span></div>
<div style="display: flex; gap: 16px">${[100, 90, 62, 42, 12].map((a) => card(over('#D9573B', GROUND, a / 100), `EMBER ${a}%`, 'LAST RUN · 8.2 KM')).join('')}</div>
</div>`;
  // Round 3's home under three ways of colouring text. Each passes the round's values with its own text colours.
  const base = vars([...roundTokens, ...swatchTokens]);
  const schemes = [
    { title: 'A · ONE COLOUR, BY OPACITY', note: 'Ember at 90 / 62 / 42%: the levels before today',
      theme: '--color-primary-text: var(--ember); --color-secondary-text: var(--ember); --color-supporting-text: var(--ember); --primary-text: 90%; --secondary-text: 62%; --secondary-text-weight: 700; --supporting-text: 42%' },
    { title: 'B · ROUND 3 NOW', note: 'Secondary text in the pale green trial at 42%; the rest ember by opacity',
      theme: '--color-primary-text: var(--ember); --color-secondary-text: #DFFFE4; --color-supporting-text: var(--ember); --primary-text: 90%; --secondary-text: 42%; --secondary-text-weight: 400; --supporting-text: 42%' },
    { title: 'C · ROLES, SOLID STEPS', note: `Entries: accent L .62 · data: information L .72 · hints: information L .52 · POWER DOWN: set apart`,
      theme: `--color-primary-text: ${step('ACCENT', 0.62)}; --color-secondary-text: ${step('INFORMATION', 0.72)}; --color-supporting-text: ${step('INFORMATION', 0.52)}; --primary-text: 100%; --secondary-text: 100%; --secondary-text-weight: 400; --supporting-text: 100%` },
  ];
  const screens = schemes.map((x) => `<div style="display: flex; flex-direction: column; gap: 10px; width: 400px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; color: #E8E8E8">${x.title}</div>
<div style="color: #9A9A9A; font-size: 11px; letter-spacing: 1px; line-height: 15px; min-height: 30px">${x.note}</div>
<dc-import name="S01-R3-Home" theme="${base}; ${x.theme}" hint-size="400px,640px"></dc-import>
</div>`).join('\n');
  const width = 32 * 2 + 7 * 150 + 6 * 16 + 120, height = 1800;
  return board({
    title: 'Palette · ramps and roles · exploration',
    fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
    body: `<div style="width: ${Math.max(width, 1400)}px; height: ${height}px; box-sizing: border-box; padding: 32px; background: #000; font-family: var(--font-interface); display: flex; flex-direction: column; gap: 32px">
<div style="display: flex; flex-direction: column; gap: 8px; max-width: 1100px">
<div style="font-size: 16px; font-weight: 700; letter-spacing: 2px; color: #E8E8E8">PALETTE · RAMPS AND ROLES · EXPLORATION</div>
<div style="color: #9A9A9A; font-size: 12px; letter-spacing: 1px; line-height: 18px">Each ramp is built around one colour, which stands in it exactly: its hue at seven steps of lightness (L), computed in OKLCH; chroma (C) eases where the screen cannot show more. Contrast is measured against the ground and the list sheet: 4.5 reads as body text, 3 as large text. Nothing here is a basic: a colour kept from this board joins the palette by name first.</div>
</div>
${rows}
${opacity}
<div style="display: flex; gap: 40px; align-items: flex-start">
${screens}
</div>
</div>`,
    script: screenScript(''),
    props: { $preview: { width: Math.max(width, 1400), height } },
  });
}

// ---- the colour grid: palette primitives, a grid of kinds by levels that picks from them, and home drawn from it ----
//
// Built like the basics: the palette is the primitives, each colour a ramp centred on it; the grid is the semantic
// tier, each cell a kind at a level, naming one step of its kind's ramp; home's parts each take a cell and a weight.
// Everything is tuned in the board's Tweaks tab and computed live by the board's own script, which runs palette.mjs's
// arithmetic.

const GRID_FILE = 'X-Colour-Grid.dc.html';
const SLOTS = 8, KINDS = 4, LEVEL_MAX = 6;
// A ramp's steps, counted from its colour: lighter above 0, darker below.
const OFFSETS = [3, 2, 1, 0, -1, -2, -3, -4];
const OFFSET_NAMES = OFFSETS.map((k) => (k > 0 ? `+${k}` : String(k)));
const SEED_SLOTS = [['Ember', '#D9573B'], ['Trial A', '#DFFFE4'], ['Cyan white', '#DDF7F5']];
const SEED_KINDS = [['Accent', 1, ['0', '-1', '-2', '-3', '—', '—']], ['Information', 2, ['-2', '-3', '-4', '-4', '—', '—']],
  ['Set apart', 3, ['0', '-2', '-3', '-4', '—', '—']], ['Kind 4', 1, ['+1', '0', '-1', '-2', '—', '—']]];
const SEED_LEVELS = ['Primary', 'Secondary', 'Supporting', 'Level 4', 'Level 5', 'Level 6'];
const CELLS = [...Array.from({ length: KINDS * LEVEL_MAX }, (_, i) => `K${Math.floor(i / LEVEL_MAX) + 1} L${(i % LEVEL_MAX) + 1}`), '—'];
// Home's parts, as round 3 draws them: what each colours, the values it passes them under, its weight at the start.
// Marks are the covers, the widgets' and list's lines and the cursor: the accent itself. 3 MORE's colour is also the
// entries' glyphs' and the handle's bar's.
const PARTS = [
  { key: 'Marks', label: 'Marks', what: 'Covers, lines, the cursor', css: ['--color-accent'], seed: 'K1 L1' },
  { key: 'Wordmark', label: 'AUBURN', v: 'header-wordmark', seed: 'K1 L1' },
  { key: 'Status', label: 'Status line', v: 'header-status', weight: 'regular', seed: 'K2 L2' },
  ...['rest', 'goals', 'cardio'].flatMap((w) => [
    { key: `${cap(w)}Name`, label: `${cap(w)} · name band`, v: `${w}-name`, weight: 'bold', seed: 'K1 L1', band: true },
    { key: `${cap(w)}Line1`, label: `${cap(w)} · line 1`, v: `${w}-line-1`, weight: 'regular', seed: 'K2 L2' },
    { key: `${cap(w)}Line2`, label: `${cap(w)} · line 2`, v: `${w}-line-2`, weight: 'regular', seed: 'K2 L2' },
  ]),
  { key: 'Handle', label: '3 MORE', v: 'list-handle', css: ['--color-supporting-text'], weight: 'bold', seed: 'K2 L3' },
  ...['START WORKOUT', 'PAST WORKOUTS', 'EXERCISES'].map((label, i) => ({ key: `Entry${i + 1}`, label, v: `entry-${i}-label`, weight: 'regular', seed: 'K1 L1' })),
  { key: 'Power', label: 'POWER DOWN', v: 'power-label', weight: 'regular', seed: 'K3 L1' },
];

// Values kept from the board's first form, with seven fixed steps of lightness and five colour hooks, carried into
// this one: a colour's step size grows, up to the most allowed, until its ramp reaches the darkest step the grid
// took from it; each step becomes the new ramp's step nearest it in lightness; a hook's cell becomes its parts'.
function migrateGrid(kept) {
  const OLD = [0.92, 0.82, 0.72, 0.62, 0.52, 0.42, 0.32];
  const val = (k, start) => (kept[k] && kept[k].default !== undefined ? kept[k].default : start);
  for (let k = 1; k <= KINDS; k++) {
    const slot = val(`k${k}Ramp`, SEED_KINDS[k - 1][1]);
    const colour = val(`p${slot}Colour`, (SEED_SLOTS[slot - 1] || [])[1]);
    if (!/^#[0-9a-f]{6}$/i.test(colour || '')) continue;
    const a = oklch(colour);
    const near = OLD.reduce((b, L) => (Math.abs(L - a.L) < Math.abs(b - a.L) ? L : b), OLD[0]);
    const cells = [];
    for (let j = 1; j <= LEVEL_MAX; j++) {
      const c = kept[`c${k}${j}`];
      if (c && /^\d\d$/.test(c.default)) cells.push([c, +c.default / 100 === near ? a.L : +c.default / 100]);
    }
    if (!cells.length) continue;
    const reach = Math.max(...cells.map(([, L]) => (L < a.L ? (a.L - L) / 4 : (L - a.L) / 3)));
    if (!kept[`p${slot}Step`]) kept[`p${slot}Step`] = { default: Math.min(0.12, Math.max(0.06, Math.ceil(reach * 100) / 100)) };
    const size = kept[`p${slot}Step`].default;
    for (const [c, L] of cells) {
      const off = Math.max(-4, Math.min(3, Math.round((L - a.L) / size)));
      c.default = off > 0 ? `+${off}` : String(off);
    }
  }
  const hooks = { homeAccent: ['Marks', 'Wordmark', 'RestName', 'GoalsName', 'CardioName'], homePrimary: ['Entry1', 'Entry2', 'Entry3'],
    homeSecondary: ['Status', 'RestLine1', 'RestLine2', 'GoalsLine1', 'GoalsLine2', 'CardioLine1', 'CardioLine2'], homeSupporting: ['Handle'], homeApart: ['Power'] };
  for (const [hook, parts] of Object.entries(hooks)) {
    if (!kept[hook]) continue;
    for (const p of parts) if (!kept[`part${p}`]) kept[`part${p}`] = { default: kept[hook].default };
  }
  return kept;
}

function gridBoard() {
  const props = {};
  const tweak = (k, meta) => { props[k] = meta; };
  for (let i = 1; i <= SLOTS; i++) {
    const [name, colour] = SEED_SLOTS[i - 1] ?? ['', '#808080'];
    tweak(`p${i}Name`, { editor: 'text', default: name, section: 'Palette · a name turns a colour on' });
    tweak(`p${i}Colour`, { editor: 'color', default: colour, section: 'Palette · a name turns a colour on' });
    tweak(`p${i}Step`, { editor: 'range', default: 0.06, min: 0.03, max: 0.12, step: 0.01, section: 'Palette · a name turns a colour on' });
  }
  tweak('darker', { editor: 'enum', options: ['fade toward the ground', 'hold chroma'], default: 'fade toward the ground', section: 'Ramps' });
  tweak('kinds', { editor: 'int', default: 3, min: 1, max: KINDS, section: 'Kinds · rows' });
  SEED_KINDS.forEach(([name, ramp], k) => {
    tweak(`k${k + 1}Name`, { editor: 'text', default: name, section: 'Kinds · rows' });
    tweak(`k${k + 1}Ramp`, { editor: 'int', default: ramp, min: 1, max: SLOTS, section: 'Kinds · rows' });
  });
  tweak('levels', { editor: 'int', default: 3, min: 2, max: LEVEL_MAX, section: 'Levels · columns' });
  SEED_LEVELS.forEach((name, j) => tweak(`l${j + 1}Name`, { editor: 'text', default: name, section: 'Levels · columns' }));
  SEED_KINDS.forEach(([, , steps], k) => steps.forEach((s, j) =>
    tweak(`c${k + 1}${j + 1}`, { editor: 'enum', options: [...OFFSET_NAMES, '—'], default: s, section: `Cells · K${k + 1}` })));
  for (const p of PARTS) tweak(`part${p.key}`, { editor: 'enum', options: CELLS, default: p.seed, section: 'Home · the cell each part takes' });
  for (const p of PARTS) if (p.weight) tweak(`weight${p.key}`, { editor: 'enum', options: ['regular', 'bold'], default: p.weight, section: 'Home · each part\'s weight' });
  tweak('greyscale', { editor: 'boolean', default: false, section: 'View' });
  // The starts the board measures changes from, before the user's values are laid over the defaults.
  const START = Object.fromEntries(Object.entries(props).map(([k, m]) => [k, m.default]));
  const kept = migrateGrid(readProps(`${OUT}/${GRID_FILE}`));
  for (const [k, m] of Object.entries(props)) if (kept[k] && kept[k].default !== undefined && (!m.options || m.options.includes(kept[k].default))) m.default = kept[k].default;
  const width = 2060, height = 1720;
  props.$preview = { width, height };
  // Home is drawn with every basic and round 3's trials, then the parts' colours and weights.
  const base = vars([...basicTokens, ...roundTokens, ...swatchTokens]);
  const H = (t) => `<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px; color: #E8E8E8">${t}</div>`;
  const N = (t) => `<div style="color: #9A9A9A; line-height: 17px">${t}</div>`;
  const body = `<div style="width: ${width}px; height: ${height}px; box-sizing: border-box; padding: 32px; background: #000; color: #E8E8E8; font-family: var(--font-interface); font-size: 12px; letter-spacing: 1px; display: flex; gap: 48px; overflow: hidden">
<div style="width: 340px; flex: none; display: flex; flex-direction: column; gap: 16px; overflow: hidden">
<div style="font-size: 16px; font-weight: 700; letter-spacing: 2px">COLOUR GRID · EXPLORATION</div>
${N('Built like the basics. The palette is the primitives: each colour you name becomes a ramp centred on it, lighter and darker by its own step size. The grid is the semantic tier: a kind is a row and picks one ramp; a level is a column; each cell names one step. Each part of home takes a cell and a weight.')}
${N('Tune everything in this board\'s Tweaks tab. Nothing here is a basic: a colour kept from this board joins the palette by name first.')}
<button type="button" onPointerDown="{{holdOn}}" onPointerUp="{{holdOff}}" onPointerLeave="{{holdOff}}" onPointerCancel="{{holdOff}}" style="{{holdStyle}}">HOLD · PREVIEW START</button>
<div style="font-weight: 700">{{status}}</div>
${H('CHANGED · {{changedCount}}')}
<sc-if value="{{noChanges}}" hint-placeholder-val="{{true}}"><div style="color: #9A9A9A">Nothing changed from the start.</div></sc-if>
<sc-for list="{{changed}}" as="c" hint-placeholder-count="3"><div style="display: flex; gap: 8px"><span style="flex: 1; font-weight: 700">{{c.name}}</span><span style="color: #9A9A9A">{{c.from}}</span><span>→ {{c.to}}</span></div></sc-for>
${H('LOG · ON THIS COMPUTER')}
<sc-if value="{{noLog}}" hint-placeholder-val="{{true}}"><div style="color: #9A9A9A">No changes seen yet.</div></sc-if>
<sc-for list="{{log}}" as="e" hint-placeholder-count="3"><div style="display: flex; gap: 8px"><span style="color: #9A9A9A">{{e.at}}</span><span style="flex: 1; font-weight: 700">{{e.name}}</span><span style="color: #9A9A9A">{{e.from}}</span><span>→ {{e.to}}</span></div></sc-for>
</div>
<div style="width: 1160px; flex: none; display: flex; flex-direction: column; gap: 32px">
<div style="display: flex; flex-direction: column; gap: 12px">
${H('PALETTE · THE PRIMITIVES')}
${N('Each ramp keeps its colour exactly at 0 and its hue throughout. Lighter steps keep its chroma until the screen cannot show it; darker steps fade toward the ground or hold chroma, as the Ramps tweak says. FADED marks a step that keeps less than two thirds of its colour\'s chroma: it no longer reads as that colour. Under each step: its contrast on the ground, then on the list sheet; 4.5 reads as body text, 3 as large text. A step the grid uses is outlined.')}
<sc-for list="{{ramps}}" as="r" hint-placeholder-count="3"><div style="display: flex; gap: 8px; align-items: flex-start">
<div style="width: 128px; flex: none; display: flex; flex-direction: column; gap: 4px"><div style="font-weight: 700">{{r.num}} · {{r.name}}</div><div style="color: #9A9A9A; font-size: 11px">{{r.anchor}}</div><div style="color: #9A9A9A; font-size: 11px">HUE {{r.hue}} · C {{r.chroma}}</div><div style="color: #9A9A9A; font-size: 11px">STEP {{r.size}}</div></div>
<sc-for list="{{r.chips}}" as="s" hint-placeholder-count="8"><div style="width: 120px; flex: none; display: flex; flex-direction: column; gap: 3px; font-size: 11px; letter-spacing: 0.5px">
<div style="{{s.swatch}}"></div>
<div style="font-weight: 700">{{s.name}}<span style="color: #E8B04B">{{s.faded}}</span></div>
<div style="color: #9A9A9A">{{s.hex}} · L {{s.l}}</div>
<div style="color: #9A9A9A">{{s.contrast}}</div>
</div></sc-for>
</div></sc-for>
</div>
<div style="display: flex; flex-direction: column; gap: 12px">
${H('GRID · KINDS BY LEVELS')}
${N('A kind is what sort of thing a text is; a level is how loud it is. Every cell shows its colour, its contrast, and the parts of home plotted on it. Under each column: the lightness its cells span. A level reads as one only while its span stays above the next level\'s.')}
<div style="display: flex; flex-direction: column; gap: 8px">
<div style="display: flex; gap: 8px"><div style="width: 128px; flex: none"></div><sc-for list="{{levelHeads}}" as="h" hint-placeholder-count="3"><div style="width: 160px; flex: none; font-weight: 700">{{h.label}}</div></sc-for></div>
<sc-for list="{{rows}}" as="row" hint-placeholder-count="3"><div style="display: flex; gap: 8px; align-items: stretch">
<div style="width: 128px; flex: none; display: flex; flex-direction: column; gap: 4px"><div style="font-weight: 700">{{row.label}}</div><div style="color: #9A9A9A; font-size: 11px">{{row.ramp}}</div></div>
<sc-for list="{{row.cells}}" as="cell" hint-placeholder-count="3"><div style="width: 160px; flex: none; box-sizing: border-box; padding: 8px; background: #1A1D1A; display: flex; flex-direction: column; gap: 4px; font-size: 11px; letter-spacing: 0.5px">
<div style="{{cell.text}}">{{cell.sample}}</div>
<div style="color: #9A9A9A">{{cell.name}}</div>
<div style="color: #9A9A9A">{{cell.contrast}}</div>
<div style="{{cell.hookStyle}}">{{cell.count}}</div>
<div style="color: #9A9A9A; line-height: 14px">{{cell.parts}}</div>
<div style="color: #E8B04B">{{cell.warn}}</div>
</div></sc-for>
</div></sc-for>
<div style="display: flex; gap: 8px"><div style="width: 128px; flex: none; color: #9A9A9A">LIGHTNESS</div><sc-for list="{{spans}}" as="sp" hint-placeholder-count="3"><div style="width: 160px; flex: none; display: flex; flex-direction: column; gap: 4px; font-size: 11px"><div style="color: #9A9A9A">{{sp.range}}</div><div style="color: #E8B04B">{{sp.warn}}</div></div></sc-for></div>
</div>
</div>
<div style="display: flex; flex-direction: column; gap: 12px">
${H('AS THE BASICS WOULD HOLD IT')}
<div style="white-space: pre; font-size: 11px; line-height: 15px; color: #9A9A9A">{{css}}</div>
</div>
</div>
<div style="width: 400px; flex: none; display: flex; flex-direction: column; gap: 16px">
${H('HOME · ROUND 3 · FROM THE GRID')}
${N('Every part at its cell\'s colour, at full strength. A part on — keeps round 3\'s own colour.')}
<div style="{{homeStyle}}"><dc-import name="S01-R3-Home" theme="{{theme}}" hint-size="400px,640px"></dc-import></div>
<div style="display: flex; flex-direction: column; gap: 6px">
<sc-for list="{{parts}}" as="p" hint-placeholder-count="18"><div style="display: flex; gap: 8px; align-items: flex-start; font-size: 11px; line-height: 14px">
<div style="{{p.swatch}}"></div>
<div style="width: 136px; flex: none; font-weight: 700">{{p.label}}</div>
<div style="flex: 1; min-width: 0; color: #9A9A9A">{{p.detail}}</div>
</div></sc-for>
</div>
</div>
</div>`;
  const script = `${COLOUR_JS}
var OFFSETS = ${JSON.stringify(OFFSETS)}, OFFSET_NAMES = ${JSON.stringify(OFFSET_NAMES)};
var GROUND = ${JSON.stringify(GROUND)}, RAISED = ${JSON.stringify(RAISED)}, INK = '#121215', GROUND_L = oklch(GROUND).L;
var SLOTS = ${SLOTS}, KINDS = ${KINDS}, LEVEL_MAX = ${LEVEL_MAX};
var PARTS = ${JSON.stringify(PARTS)};
var START = ${JSON.stringify(START)};
var BASE = ${JSON.stringify(base)};
var LOG_KEY = ${JSON.stringify(`auburn.log.${GRID_FILE}`)};
var f2 = function (n) { return n.toFixed(2).replace(/^0/, ''); };
var f1 = function (n) { return n.toFixed(1); };
var slug = function (s) { return String(s).trim().toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''); };
var stepCss = function (name, k) { return '--' + slug(name) + (k > 0 ? '-lighter-' + k : k < 0 ? '-darker-' + (-k) : ''); };
class Component extends DCLogic {
constructor(props) {
super(props);
var log = [];
try { log = JSON.parse(window.localStorage.getItem(LOG_KEY) || '[]'); } catch (e) {}
this.state = { holding: false, log: log };
}
value(k, props) { var v = props[k]; return v == null ? START[k] : v; }
// Every change the board sees is logged, newest first, and kept on this computer.
componentDidUpdate(prev) {
var self = this, added = [];
var now = new Date(), at = ('0' + now.getHours()).slice(-2) + ':' + ('0' + now.getMinutes()).slice(-2);
Object.keys(START).forEach(function (k) {
var a = String(self.value(k, prev)), b = String(self.value(k, self.props));
if (a !== b) added.push({ at: at, name: k, from: a, to: b });
});
if (!added.length) return;
var log = added.concat(this.state.log).slice(0, 40);
try { window.localStorage.setItem(LOG_KEY, JSON.stringify(log)); } catch (e) {}
this.setState({ log: log });
}
renderVals() {
var self = this, holding = this.state.holding, props = holding ? {} : this.props;
var v = function (k) { return self.value(k, props); };
var clamp = function (n, lo, hi) { n = Math.round(Number(n)); return isNaN(n) ? lo : Math.max(lo, Math.min(hi, n)); };
var fade = v('darker') !== 'hold chroma';
// The primitives: every named colour, as a ramp centred on it.
var slots = [];
for (var i = 1; i <= SLOTS; i++) {
var name = String(v('p' + i + 'Name') || '').trim(), colour = String(v('p' + i + 'Colour') || '');
if (!name || !/^#[0-9a-f]{6}$/i.test(colour)) { slots.push(null); continue; }
var a = oklch(colour);
var size = Math.max(0.01, Number(v('p' + i + 'Step')) || 0.06);
slots.push({ num: i, name: name, anchor: colour.toUpperCase(), hue: Math.round(a.H), chroma: a.C.toFixed(3), size: size.toFixed(2).replace(/^0/, ''), steps: rampFrom(colour, OFFSETS, size, fade, GROUND_L) });
}
var kinds = clamp(v('kinds'), 1, KINDS), levels = clamp(v('levels'), 2, LEVEL_MAX);
var levelName = function (j) { return String(v('l' + j + 'Name') || 'Level ' + j); };
// The grid: each kind takes a ramp, each cell a step of it.
var grid = [];
for (var k = 1; k <= KINDS; k++) {
var slot = slots[clamp(v('k' + k + 'Ramp'), 1, SLOTS) - 1];
var row = { k: k, name: String(v('k' + k + 'Name') || 'Kind ' + k), slot: slot, cells: [] };
for (var j = 1; j <= LEVEL_MAX; j++) {
var pick = String(v('c' + k + j)), at = OFFSET_NAMES.indexOf(pick);
var s = slot && at >= 0 ? slot.steps[at] : null;
row.cells.push({ id: 'K' + k + ' L' + j, k: k, j: j, step: at >= 0 ? OFFSETS[at] : null, s: s, slot: slot ? slot.num : null, name: s ? slot.name.toUpperCase() + ' ' + pick : 'EMPTY' });
}
grid.push(row);
}
var cellOf = function (id) { var m = /^K(\\d) L(\\d)$/.exec(id); return m ? grid[+m[1] - 1].cells[+m[2] - 1] : null; };
var on = function (c) { return c && c.k <= kinds && c.j <= levels && c.s; };
// Home's parts on the grid.
var parts = PARTS.map(function (p) { var c = cellOf(String(v('part' + p.key))); return { p: p, c: c, ok: !!on(c), bold: p.weight ? v('weight' + p.key) === 'bold' : null }; });
// The steps in use, by ramp and step: two ramps may share a colour.
var used = {};
parts.forEach(function (x) { if (x.ok) used[x.c.slot + ':' + x.c.step] = true; });
grid.forEach(function (r) { r.cells.forEach(function (c) { if (on(c)) used[c.slot + ':' + c.step] = true; }); });
var ramps = slots.filter(Boolean).map(function (sl) {
return { num: sl.num, name: sl.name.toUpperCase(), anchor: sl.anchor, hue: sl.hue, chroma: sl.chroma, size: sl.size, chips: sl.steps.map(function (s, n) {
return { name: (s.anchor ? '● ' : '') + OFFSET_NAMES[n], faded: s.white ? ' · AT WHITE' : s.faded ? ' · FADED' : '', hex: s.hex, l: f2(s.L),
contrast: f1(contrast(s.hex, GROUND)) + ' · ' + f1(contrast(s.hex, RAISED)),
swatch: 'height: 32px; box-sizing: border-box; background: ' + s.hex + '; border: 2px solid ' + (used[sl.num + ':' + s.k] ? '#E8E8E8' : 'transparent') };
}) };
});
var rows = grid.slice(0, kinds).map(function (r) {
return { label: 'K' + r.k + ' · ' + r.name.toUpperCase(), ramp: r.slot ? 'RAMP ' + r.slot.num + ' · ' + r.slot.name.toUpperCase() : 'NO COLOUR ON RAMP ' + clamp(v('k' + r.k + 'Ramp'), 1, SLOTS),
cells: r.cells.slice(0, levels).map(function (c, n) {
var here = parts.filter(function (x) { return x.ok && x.c === c; });
var left = n > 0 ? r.cells[n - 1] : null;
return { sample: c.s ? 'LAST RUN · 8.2 KM' : '—', name: c.name + (c.s && c.s.faded ? ' · FADED' : ''), text: 'font-weight: 700; color: ' + (c.s ? c.s.hex : '#555') + '; white-space: nowrap; overflow: hidden',
contrast: c.s ? 'L ' + f2(c.s.L) + ' · ' + f1(contrast(c.s.hex, GROUND)) + ' · ' + f1(contrast(c.s.hex, RAISED)) : '',
count: here.length ? here.length + ' PART' + (here.length === 1 ? '' : 'S') : 'NOTHING ON HOME',
parts: here.map(function (x) { return x.p.label; }).join(' · '),
hookStyle: here.length ? 'font-weight: 700' : 'color: #555',
warn: c.s && left && left.s && c.s.L >= left.s.L ? 'NOT DIMMER THAN ' + levelName(n).toUpperCase() : '' };
}) };
});
var levelHeads = [];
for (var j = 1; j <= levels; j++) levelHeads.push({ label: 'L' + j + ' · ' + levelName(j).toUpperCase() });
// Each level's span of lightness across the kinds, and whether it overlaps the next.
var span = function (j) { var ls = grid.slice(0, kinds).map(function (r) { return r.cells[j - 1].s; }).filter(Boolean).map(function (s) { return s.L; }); return ls.length ? { lo: Math.min.apply(null, ls), hi: Math.max.apply(null, ls) } : null; };
var spans = levelHeads.map(function (h, n) {
var a = span(n + 1), b = n + 1 < levels ? span(n + 2) : null;
return { range: a ? 'L ' + f2(a.lo) + ' – ' + f2(a.hi) : 'NO CELLS', warn: a && b && b.hi >= a.lo ? 'OVERLAPS ' + levelName(n + 2).toUpperCase() : '' };
});
// Home: each part's colour and weight, passed under its own names.
var theme = BASE + '; --primary-text: 100%; --secondary-text: 100%; --supporting-text: 100%';
parts.forEach(function (x) {
if (x.ok) {
(x.p.css || []).forEach(function (c) { theme += '; ' + c + ': ' + x.c.s.hex; });
if (x.p.v) theme += '; --' + x.p.v + '-color: ' + x.c.s.hex;
}
if (x.p.v && x.bold != null) theme += '; --' + x.p.v + '-weight: ' + (x.bold ? 700 : 400);
});
var partRows = parts.map(function (x) {
var c = x.c, where = c ? (x.ok ? 'K' + c.k + ' L' + c.j + ' · ' + c.name : 'OFF THE GRID') : 'ROUND 3\\'S OWN';
var detail = where + (x.bold != null ? ' · ' + (x.bold ? 'BOLD' : 'REGULAR') : '') + (x.ok ? ' · ' + f1(contrast(x.c.s.hex, x.p.band ? INK : GROUND)) + (x.p.band ? ' INK ON IT' : '') : '') + (x.p.what ? ' · ' + x.p.what : '');
return { label: x.p.label.toUpperCase(), detail: detail,
swatch: 'width: 16px; height: 16px; flex: none; background: ' + (x.ok ? c.s.hex : 'transparent') + '; border: 1px solid #555' };
});
// The result, written as basics.css would hold it: the steps the grid uses as primitives, the cells as semantic values.
var lines = ['/* Palette */'];
slots.filter(Boolean).forEach(function (sl) { sl.steps.forEach(function (s) { if (used[sl.num + ':' + s.k]) lines.push(stepCss(sl.name, s.k) + ': ' + s.hex + ';'); }); });
lines.push('', '/* Colour: a kind at a level */');
grid.slice(0, kinds).forEach(function (r) { r.cells.slice(0, levels).forEach(function (c) { if (c.s) lines.push('--color-' + slug(r.name) + '-' + slug(levelName(c.j)) + ': var(' + stepCss(r.slot.name, c.step) + ');'); }); });
var changed = Object.keys(START).map(function (k) { return { name: k, from: String(START[k]), to: String(v(k)) }; }).filter(function (c) { return c.from !== c.to; });
return {
ramps: ramps, rows: rows, levelHeads: levelHeads, spans: spans, parts: partRows, theme: theme, css: lines.join('\\n'),
homeStyle: 'width: 400px; height: 640px; overflow: hidden' + (v('greyscale') === true || v('greyscale') === 'true' ? '; filter: grayscale(1)' : ''),
changed: changed, changedCount: changed.length, noChanges: changed.length === 0,
log: this.state.log.slice(0, 16), noLog: this.state.log.length === 0,
status: holding ? 'SHOWING THE START' : 'SHOWING YOUR VALUES',
holdOn: function () { self.setState({ holding: true }); },
holdOff: function () { if (self.state.holding) self.setState({ holding: false }); },
holdStyle: 'height: 44px; padding: 0 14px; font-family: inherit; font-size: 13px; font-weight: 700; letter-spacing: 1.5px; cursor: pointer; touch-action: none; user-select: none; border: 2px solid #E8E8E8; background: ' + (holding ? '#E8E8E8' : 'transparent') + '; color: ' + (holding ? '#000' : '#E8E8E8')
};
}
}`;
  return board({
    title: 'Colour grid · exploration',
    fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
    body, script, props,
  });
}

const files = {
  'X-Palette.dc.html': paletteBoard(),
  [GRID_FILE]: gridBoard(),
  ...parts, ...partsRound, ...boot, ...agreed, ...round3,
  'Theme.dc.html': controlBoard({
    file: 'Theme.dc.html', title: 'Theme', heading: 'THEME', note: 'Every agreed screen.',
    toks: [...basicTokens, ...swatchTokens], width: W, height: 1456,
    rows: [
      { label: 'SCREEN 01 · NAVIGATION · AGREED', boards: Object.keys(agreed) },
      { label: 'SCREEN 00 · BOOT · AGREED', boards: Object.keys(boot) },
    ],
  }),
  // The component rounds with the screen that uses them: round 3's screens, at the round's starting values.
  'C-R3-Screens.dc.html': board({
    title: 'Component rounds · in screen 01, round 3',
    fonts: 'family=Gelasio:wght@700&amp;family=Courier+Prime:wght@400;700',
    body: `<div style="width: ${rowWidth(Object.keys(round3).length) - 412}px; height: 760px; box-sizing: border-box; padding: 32px; background: #000; color: var(--cyan-white); font-family: var(--font-interface); display: flex; flex-direction: column; gap: 12px">
<div style="font-size: 13px; font-weight: 700; letter-spacing: 2px">SCREEN 01 · ROUND 3 · AT THE ROUND'S STARTING VALUES · TUNE ON THE 01 PAGE'S ROUND BOARD</div>
<div style="display: flex; gap: 40px; align-items: flex-start">
${Object.keys(round3).map((b) => `<dc-import name="${b.replace('.dc.html', '')}" hint-size="400px,640px"></dc-import>`).join('\n')}
</div>
</div>`,
    script: screenScript(''),
    props: { $preview: { width: rowWidth(Object.keys(round3).length) - 412, height: 760 } },
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
copyFileSync(BASICS, `${OUT}/basics.css`);

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
// Component rounds, below the agreed components: round 3's copies, then the screens that use them.
y += 300;
index.notes.componentsR3 = index.notes.componentsR3 || { kind: 'title1', maxW: 2400, page: 'components', text: "Component rounds — for screen 01's round 3 · in progress", w: 240, x: 0, y: y - 300 };
for (const c of COMPONENTS) {
  const s = partsRound[`${boardOf(c.tag, true)}-States.dc.html`].match(/"\$preview":\{"width":(\d+),"height":(\d+)\}/);
  const p = partsRound[`${boardOf(c.tag, true)}.dc.html`].match(/"\$preview":\{"width":(\d+),"height":(\d+)\}/);
  place(`${boardOf(c.tag, true)}-States.dc.html`, { page: 'components', title: `${cap(c.name)} · states · round 3 · in progress`, w: +s[1], h: +s[2], x: 0, y });
  place(`${boardOf(c.tag, true)}.dc.html`, { page: 'components', title: `${cap(c.name)} · round 3 · in progress · tune its properties in the Tweaks tab`, w: +p[1], h: +p[2], x: +s[1] + 80, y, is_interactive: true });
  y += Math.max(+s[2], +p[2]) + 120;
}
place('C-R3-Screens.dc.html', { page: 'components', title: 'Component rounds · in screen 01, round 3 · in progress', w: rowWidth(Object.keys(round3).length) - 412, h: 760, x: 0, y });
Object.keys(boot).forEach((n, i) => place(n, { page: 's00', title: `Boot · ${i ? 'light' : 'dark'} · agreed`, w: 400, h: 640, x: i * 480, y: 7460 }));
delete index.notes.basics;
index.notes.theme = index.notes.theme || { kind: 'title1', maxW: W, page: 'basics', text: 'Theme — every agreed screen, tuned at once', w: 240, x: 0, y: -300 };
index.notes.s01r3 = index.notes.s01r3 || { kind: 'title1', maxW: 2320, page: 's01', text: 'Round 3 — screen 01 on the type and spacing scales', w: 240, x: 0, y: 10280 };
index.notes.s01r3board = index.notes.s01r3board || { kind: 'title1', maxW: W, page: 's01', text: 'Round 3 — tune here; changes stay on this board', w: 240, x: 0, y: 11200 };
index.notes.s01agreed = index.notes.s01agreed || { kind: 'title1', maxW: 2320, page: 's01', text: 'Screen 01 — agreed', w: 240, x: 0, y: 12340 };
// The palette exploration, below the Explorations page's earlier rounds.
const paletteW = +files['X-Palette.dc.html'].match(/"\$preview":\{"width":(\d+)/)[1];
place('X-Palette.dc.html', { page: 'design', title: 'Palette · ramps and roles · exploration', w: paletteW, h: 1800, x: 0, y: 3548 });
index.notes.palette = index.notes.palette || { kind: 'title1', maxW: paletteW, page: 'design', text: 'Palette — ramps and roles', w: 240, x: 0, y: 3268 };
// The colour grid, below the palette.
const gridW = +files[GRID_FILE].match(/"\$preview":\{"width":(\d+)/)[1];
place(GRID_FILE, { page: 'design', title: 'Colour grid · tune in the Tweaks tab · exploration', w: gridW, h: 1720, x: 0, y: 5768, is_interactive: true });
index.notes.colourGrid = index.notes.colourGrid || { kind: 'title1', maxW: gridW, page: 'design', text: 'Colour grid — palette, kinds and levels', w: 240, x: 0, y: 5488 };
index.notes.s00agreed = index.notes.s00agreed || { kind: 'title1', maxW: 880, page: 's00', text: 'Boot · agreed', w: 240, x: 0, y: 7180 };
writeFileSync(`${OUT}/canvas.json`, `${JSON.stringify(index, null, 2)}\n`);

console.log('Built:', Object.keys(files).join(', '), '+ basics.css, canvas.json');
if (Object.keys(leftovers).length) console.log('Left off the spacing scale:', leftovers);
