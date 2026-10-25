// Renders every agreed screen's state images from its screen.html.
//
// Each Spec/Visual Design/<nn-screen>/screen.html lists its images in one line:
//   <meta name="images" content="name: <query or hash> | <selector>; ...">
// Every listed state is saved as <name>.png beside the file, at the element's own size.
// Run from the repository root after any design change: node Tools/render-screens.mjs
// Needs Node and Playwright (npm install playwright; npx playwright install chromium).

import { createRequire } from 'node:module';
import { readdirSync, existsSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const { chromium } = createRequire(import.meta.url)('playwright');
const root = resolve('Spec/Visual Design');

const decode = (s) => s.replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>');

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 2400, height: 1000 } });
for (const dir of readdirSync(root, { withFileTypes: true })) {
  const html = join(root, dir.name, 'screen.html');
  if (!dir.isDirectory() || !existsSync(html)) continue;
  const meta = readFileSync(html, 'utf8').match(/<meta name="images" content="([^"]*)">/);
  if (!meta) {
    console.log(`${dir.name}: no images listed`);
    continue;
  }
  for (const entry of decode(meta[1]).split(';').map((e) => e.trim()).filter(Boolean)) {
    const [name, rest] = entry.split(/:\s*/, 2);
    const [suffix, selector] = rest.split('|').map((p) => p.trim());
    await page.goto(pathToFileURL(html).href + suffix);
    await page.waitForLoadState('networkidle');
    await page.evaluate(() => document.fonts.ready);
    const out = join(root, dir.name, `${name}.png`);
    await page.locator(selector).first().screenshot({ path: out });
    console.log(`${dir.name}/${name}.png`);
  }
}
await browser.close();
