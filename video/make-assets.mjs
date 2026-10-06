// Рендер графіки з assets/frames.html → work/gfx/*.png (1920×1080, прозорість зберігається)
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const SRC = new URL('./assets/frames.html', import.meta.url).href;
const OUT = fileURLToPath(new URL('./work/gfx/', import.meta.url));
mkdirSync(OUT, { recursive: true });

const b = await chromium.launch();
const p = await b.newPage({ viewport: { width: 1920, height: 1080 } });
for (const m of ['bg3', 'bg4', 'bg5', 'frame', 'title', 'end']) {
  await p.goto(`${SRC}#${m}`); await p.reload(); // hash-навігація без reload не перезапускає скрипт
  await p.waitForLoadState('networkidle'); await p.evaluate(() => document.fonts.ready);
  await p.screenshot({ path: `${OUT}${m}.png`, omitBackground: true });
}
await b.close();
console.log('ok');
