// Запис екранних сцен 3–5 з prototype/index.html#rec → work/rec/scene{3,4,5}.webm
// Вʼюпорт 780×1688 при zoom 2 = телефон 390×844 у 2× — чіткий кадр без апскейлу.
// Запуск: node record.mjs   (playwright — через node_modules-симлінк)
import { chromium } from 'playwright';
import { mkdirSync, renameSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const URL = new globalThis.URL('../prototype/index.html#rec', import.meta.url).href;
const OUT = fileURLToPath(new globalThis.URL('./work/rec/', import.meta.url));
const SIZE = { width: 780, height: 1688 };
mkdirSync(OUT, { recursive: true });

const MON = ['січня','лютого','березня','квітня','травня','червня','липня','серпня','вересня','жовтня','листопада','грудня'];
const t = new Date(); t.setDate(t.getDate() + 1);
const BOOKED = { booked: { doc: 'Гриценко Оксана Миколаївна', time: '10:30', date: `${t.getDate()} ${MON[t.getMonth()]}`,
  short: `${t.getDate()}.${String(t.getMonth() + 1).padStart(2, '0')}`, note: 'Болить зуб праворуч' } };

// Видимий дотик: коло в місці натискання (курсора у записі немає).
const TAP = () => {
  addEventListener('pointerdown', e => {
    const z = 2, d = document.createElement('div');
    d.style.cssText = `position:fixed;left:${e.clientX / z - 22}px;top:${e.clientY / z - 22}px;width:44px;height:44px;border-radius:50%;
      background:rgba(27,77,158,.25);border:2px solid rgba(27,77,158,.6);pointer-events:none;z-index:99;transition:transform .45s,opacity .45s`;
    document.body.appendChild(d);
    requestAnimationFrame(() => { d.style.transform = 'scale(1.6)'; d.style.opacity = '0'; });
    setTimeout(() => d.remove(), 500);
  }, true);
};

const b = await chromium.launch();
const offsets = {};

async function scene(name, state, act) {
  const ctx = await b.newContext({ viewport: SIZE, recordVideo: { dir: OUT, size: SIZE } });
  const t0 = Date.now();
  await ctx.addInitScript(TAP);
  await ctx.addInitScript(s => { try { s ? localStorage.setItem('im-clinic-proto', JSON.stringify(s)) : localStorage.clear(); } catch {} }, state);
  const p = await ctx.newPage();
  await p.goto(URL); await p.evaluate(() => document.fonts.ready); await p.waitForTimeout(300);
  offsets[name] = (Date.now() - t0) / 1000; // з цієї секунди сцена готова — до неї обрізаємо
  const w = ms => p.waitForTimeout(ms);
  const tap = async sel => { await p.locator(sel).first().click(); };
  const scroll = (sel, ms = 900) => p.evaluate(([s]) => {
    const app = document.getElementById('app'), el = document.querySelector(s);
    app.scrollTo({ top: el.offsetTop - 20, behavior: 'smooth' });
  }, [sel]).then(() => w(ms));
  await act({ p, w, tap, scroll });
  const v = p.video(); await ctx.close();
  renameSync(await v.path(), `${OUT}${name}.webm`);
}

// Вступ 0b: застосунок клініки — головна, повільний скрол, вкладка «Клініка»
await scene('scene0b', BOOKED, async ({ p, w, tap, scroll }) => {
  await w(2200); await scroll('.quick', 2200);
  await tap('#tabs [data-tab="clinic"]'); await w(3500);
});

// Вступ 0c: пуш персональної пропозиції (за згодою) → бали й запрошення
await scene('scene0c', BOOKED, async ({ p, w, tap }) => {
  await w(1500);
  await p.evaluate(() => { // текст — як у картці «Пропозиція для вас» живого демо
    document.getElementById('push-title').textContent = 'Пропозиція для вас';
    document.getElementById('push-text').textContent = 'Минув рік — у клініці для вас персональна пропозиція. Умови — на рецепції.';
    document.getElementById('push').classList.add('show');
  });
  await w(3800); await p.evaluate(() => document.getElementById('push').classList.remove('show'));
  await w(700); await tap('#app [data-go="loyalty"]'); await w(4500);
});

// CJM 3: після рецепції — візит уже в застосунку, пуш «Завтра візит»
await scene('visit', BOOKED, async ({ p, w }) => {
  await w(2500); await p.keyboard.press('n'); await w(5000);
});

// CJM 5: вдома — памʼятка з галочками → «коли дзвонити терміново»
await scene('memo', BOOKED, async ({ p, w, tap, scroll }) => {
  await w(600); await tap('#tabs [data-tab="care"]');
  await w(1400); await tap('[data-memo="5"]');
  await w(900); await scroll('.urgent', 1800);
  await w(1200);
});

// CJM 6: Лікування → формула → етапи → погодження плану
await scene('plan', BOOKED, async ({ p, w, tap, scroll }) => {
  await w(600); await tap('#tabs [data-tab="plan"]');
  await w(1600); await scroll('.film', 1300);
  await scroll('.stage', 1300);
  await scroll('.warn', 1300);
  await scroll('[data-accept]', 900); await tap('[data-accept]');
  await w(1800);
});

writeFileSync(`${OUT}offsets.json`, JSON.stringify(offsets, null, 2));
await b.close();
console.log('ok', offsets);
