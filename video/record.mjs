// Запис екранних сцен з prototype/index.html#rec → work/rec/*.webm (scene0b, scene0c, tour, memo, plan)
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

async function scene(name, state, act, init) {
  const ctx = await b.newContext({ viewport: SIZE, recordVideo: { dir: OUT, size: SIZE } });
  const t0 = Date.now();
  await ctx.addInitScript(TAP);
  if (init) await ctx.addInitScript(init); // напр. екран вітання — ще до першого кадру, щоб під ним не просвічувала головна
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

// CJM 5: після процедури Анна відсканувала QR на рецепції → застосунок клініки відкривається:
// вітання й PIN (як у живому вході: посилання від рецепції + PIN) → головна з пушем «Завтра візит» → огляд вкладок
const WELCOME = () => addEventListener('DOMContentLoaded', () => {
  const o = document.createElement('div'); o.id = 'welcome';
  o.style.cssText = 'position:absolute;inset:0;z-index:20;background:var(--ground,#F4F6F6);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;font-family:inherit;transition:opacity .45s';
  o.innerHTML = '<img src="logo.png" style="width:84px;height:84px;border-radius:22px;margin-bottom:10px">'
    + '<b style="font-size:24px">IM Dental Demo</b><span style="color:#5E6D74;font-size:15px">Кабінет пацієнта</span>'
    + '<span style="margin-top:28px;font-size:16px;font-weight:600">Придумайте PIN-код</span>'
    + '<div id="pin" style="display:flex;gap:16px;margin-top:6px">' + '<i style="width:16px;height:16px;border-radius:50%;border:2px solid #1B4D9E;display:block;transition:background .15s"></i>'.repeat(4) + '</div>';
  document.querySelector('.phone').appendChild(o);
});
await scene('tour', BOOKED, async ({ p, w, tap }) => {
  await w(900);
  for (let i = 0; i < 4; i++) { await p.evaluate(n => { document.querySelectorAll('#pin i')[n].style.background = '#1B4D9E'; }, i); await w(230); }
  await w(350); await p.evaluate(() => { const o = document.getElementById('welcome'); o.style.opacity = '0'; setTimeout(() => o.remove(), 450); });
  await w(1200); await p.keyboard.press('n'); await w(2600);
  await p.evaluate(() => document.getElementById('push').classList.remove('show')); await w(500);
  for (const t of ['plan', 'care', 'clinic']) { await tap(`#tabs [data-tab="${t}"]`); await w(1500); }
}, WELCOME);

// CJM 6: вдома — памʼятка з галочками → «коли дзвонити терміново»
await scene('memo', BOOKED, async ({ p, w, tap, scroll }) => {
  await w(600); await tap('#tabs [data-tab="care"]');
  await w(1400); await tap('[data-memo="5"]');
  await w(900); await scroll('.urgent', 1800);
  await w(1200);
});

// CJM 7: Лікування → формула → етапи → погодження плану
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
