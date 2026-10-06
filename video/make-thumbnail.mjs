// Мініатюра YouTube 1280×720 → thumbnail.png (у git) і work/thumbnail.jpg
// 1) знімок екрана «Лікування» з prototype/index.html (390×844 у 2×) → work/gfx/thumb-screen.png
// 2) рендер assets/thumbnail.html
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const u = p => new URL(p, import.meta.url);
mkdirSync(fileURLToPath(u('./work/gfx/')), { recursive: true });
const b = await chromium.launch(process.env.CHROMIUM ? { executablePath: process.env.CHROMIUM } : {});

const ctx = await b.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
await ctx.addInitScript(() => { try { localStorage.clear(); } catch {} });
const p = await ctx.newPage();
await p.goto(u('../prototype/index.html').href);
await p.evaluate(() => document.fonts.ready);
await p.click('[data-tab="plan"]');
await p.waitForTimeout(400);
await p.screenshot({ path: fileURLToPath(u('./work/gfx/thumb-screen.png')) });
await ctx.close();

const t = await b.newPage({ viewport: { width: 1280, height: 720 } });
await t.goto(u('./assets/thumbnail.html').href);
await t.waitForLoadState('networkidle'); await t.evaluate(() => document.fonts.ready);
await t.screenshot({ path: fileURLToPath(u('./thumbnail.png')) });
await t.screenshot({ path: fileURLToPath(u('./work/thumbnail.jpg')), type: 'jpeg', quality: 92 });
await b.close();
console.log('ok: video/thumbnail.png');
