// Renders every agreed screen's and component's state images from its screen.html or component.html.
//
// Each Spec/Visual Design/<nn-screen>/screen.html and components/<name>/component.html lists its images in one line:
//   <meta name="images" content="name: <query or hash> | <selector>; ...">
// Every listed state is saved as <name>.png beside the file, at the element's own size, with animations held at
// their start so every run gives the same image. components.js is built first.
// Run from the repository root after any design change: node Tools/render-screens.mjs
// Needs Node and Playwright (npm install playwright; npx playwright install chromium).

import { createRequire } from 'node:module';
import { readdirSync, existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { build } from './build-components.mjs';

const { chromium } = createRequire(import.meta.url)('playwright');
const root = resolve('Spec/Visual Design');

const decode = (s) => s.replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>');

build();
const files = [
  ...readdirSync(root, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => join(root, d.name, 'screen.html')),
  ...readdirSync(join(root, 'components'), { withFileTypes: true }).filter((d) => d.isDirectory())
    .map((d) => join(root, 'components', d.name, 'component.html')),
].filter((f) => existsSync(f));

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 2400, height: 1000 } });
for (const html of files) {
  const where = html.slice(root.length + 1, html.lastIndexOf('/'));
  const meta = readFileSync(html, 'utf8').match(/<meta name="images" content="([^"]*)">/);
  if (!meta) {
    console.log(`${where}: no images listed`);
    continue;
  }
  for (const entry of decode(meta[1]).split(';').map((e) => e.trim()).filter(Boolean)) {
    const [name, rest] = entry.split(/:\s*/, 2);
    const [suffix, selector] = rest.split('|').map((p) => p.trim());
    await page.goto(pathToFileURL(html).href + suffix);
    await page.waitForLoadState('networkidle');
    await page.evaluate(() => document.fonts.ready);
    const out = join(root, where, `${name}.png`);
    await page.locator(selector).first().screenshot({ path: out, animations: 'disabled' });
    console.log(`${where}/${name}.png`);
  }
}
await browser.close();
