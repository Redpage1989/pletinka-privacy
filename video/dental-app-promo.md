# Промо-відео IM Clinic: кабінет пацієнта стоматклініки

Формат: YouTube, 16:9 (1920×1080), 98 с (25 с вступу для клінік + 73 с ролика), українська озвучка, субтитри `.srt`.
Опис, теги й розділи для YouTube: `youtube.md`.
Бренд, кольори й реальний список функцій: `brand-im-clinic.md`. Екрани: `prototype/index.html` (бренд демо IM Clinic, акцент `#1B4D9E`, шрифт Geologica).
Застосунок white-label: у кадрі демо-бренд IM Clinic, пацієнт реальної клініки бачить її назву й логотип.

## Принцип збірки
- Кадри з людьми та кабінетом генеруємо в Higgsfield (image-to-video, 5 с, 16:9).
- Інтерфейс застосунку НЕ генеруємо: записуємо екран реального застосунку або HTML-прототипу.
- Одна героїня в усіх кадрах: спершу створити її в Higgsfield (Soul ID / референс-фото), далі використовувати як референс.
- Текст на екрані, логотип і CTA додаємо в монтажі, не в Higgsfield.
- Озвучку робимо окремо (ElevenLabs або інший TTS з українською, перевірити наголоси).

## Сценарій

| # | Час | Візуал | Озвучка (UA) | Екранний текст |
|---|-----|--------|--------------|----------------|
| 0 | 0:00–0:25 | ЗАСТАВКА «Вітаємо!» → застосунок клініки → пуш пропозиції й бали | «Вітаємо! Ми — компанія IM…» (повністю — `озвучка-elevenlabs.txt`, 00) | Вітаємо! · IM Clinic |
| 1 | 0:25–0:31 | HIGGS `pain`: у Анни зранку болить зуб | «Зранку заболів зуб. Анна йде туди, де їй допоможуть, — у клініку.» | — |
| 2 | 0:31–0:36 | HIGGS `reception`: рецепція записує Анну до лікаря | «На рецепції Анну одразу записують до лікаря.» | — |
| 3 | 0:36–0:40 | HIGGS `relief`: лікар знімає біль | «Лікар знімає біль. Найважче — позаду.» | — |
| 4 | 0:40–0:47 | HIGGS `qr`: **після процедури** Анна сканує телефоном QR-код на стійці рецепції | «Після процедури Анна сканує QR-код на рецепції — і застосунок клініки вже в її телефоні.» | IM Clinic · кабінет пацієнта вашої клініки |
| 5 | 0:47–0:58 | ЗАПИС ЕКРАНА `tour`: вітання клініки й PIN → Головна з візитом і пушем «Завтра візит» → Лікування → Догляд → Клініка | «Тут усе: візит і нагадування, план лікування, памʼятки, гарантії і контакти клініки.» | Усе — в одному застосунку |
| 6 | 0:58–1:05 | ЗАПИС ЕКРАНА `memo`: памʼятка з галочками → «коли дзвонити терміново» | «А вдома — памʼятка після процедури…» | Памʼятка після процедури |
| 7 | 1:05–1:12 | ЗАПИС ЕКРАНА `plan`: залишок → зубна формула → етапи → «що буде, якщо чекати» → «Погодити план» | «Далі — план лікування з етапами й сумами. Погодити його можна просто в телефоні.» | План лікування |
| 8 | 1:12–1:19 | HIGGS `scene6`: лікар показує Анні план на планшеті | «Лікар пояснює план своїми словами…» | — |
| 9 | 1:19–1:24 | HIGGS `scene7`: Анна виходить з клініки й широко, щасливо усміхається в камеру (видно зуби) | «Здорова усмішка. І клініка, яка завжди поруч.» | — |
| 10 | 1:24–1:38 | Знак IM + «IM Clinic» на тлі `#0A151D`, QR на im.pl.ua/clinic, блок «Для клінік: CRM» | «Попросіть посилання на рецепції своєї клініки. А для клінік: … CRM … Посилання — в описі.» | im.pl.ua/clinic |

Функції в кадрах 3–5 звірено з кодом застосунку (PureApp) і уроком `clinic.mp4`. Не обіцяти: онлайн-оплату, чат, знімки в застосунку, App Store / Google Play (це PWA, ставиться з браузера).

## Промпти для Higgsfield (англійською — так стабільніше)

Стиль для всіх: `bright modern dental clinic, soft natural daylight, clean white and deep blue (#1B4D9E) palette, cinematic shallow depth of field, warm and reassuring mood, 16:9`

**Героїня (референс, спершу картинка):**
`Portrait of a friendly Ukrainian woman, 32 years old, shoulder-length light-brown hair, casual beige cardigan, natural smile, soft window light, neutral background, photorealistic`

**Кадр 1:** `Same woman sits on a sofa at home holding a smartphone, looks slightly worried, glances at a wall calendar, slow push-in, soft daylight, photorealistic`

**Кадр 2:** `Same woman looks at the phone screen and smiles with relief, subtle head movement, shallow depth of field, phone screen not visible to camera, slow dolly in`

**Кадр QR (`clips/qr.mp4`, сцена 4):** `Same woman stands at the reception desk of a bright modern dental clinic right after her treatment, relieved and smiling, holds up her smartphone and scans a QR code on a small white table stand on the counter, over-the-shoulder medium close-up of the phone pointed at the stand, friendly receptionist smiling in soft focus behind the desk, clean white and deep blue (#1B4D9E) interior, soft daylight, photorealistic, 16:9`
Уникати: читабельного тексту й логотипів на стійці та екрані телефона. Сам застосунок у ролику показує запис екрана (сцена 5).

**Кадр 6:** `Friendly female dentist in white coat shows a tablet to a smiling patient in a modern dental office, over-the-shoulder shot, gentle camera move, tablet screen out of focus`

**Кадр 7 (`clips/scene7.mp4`, фінал):** `Same woman walks out of a modern clinic entrance into a sunny street, turns to the camera and breaks into a wide, genuinely happy smile showing healthy natural white teeth, eyes crinkling with joy, relaxed shoulders, light breeze in hair, medium close-up so the smile is clearly visible, slow tracking shot from the front, warm daylight, photorealistic`
Вимога до дубля: щаслива усмішка з видимими зубами тримається щонайменше останні 2–3 с кліпу. Зуби природні й здорові, не «голлівудські». Згенерувати 3–4 варіанти й обрати той, де усмішка найщиріша.

Негатив/уникати: текст на екранах, логотипи, зуби крупним планом із дефектами, надмірно «ідеальні» голлівудські зуби.

## Збірка (06.10.2026; сюжет із QR після процедури — 07.10.2026, ролик 98 с)
Кліпи Higgsfield: героїня — елемент `Anna-IMClinic` (GPT Image 2), стартові кадри 16:9 → Kling 3.0, 5 с, 1080p, без звуку
(Seedance 2.0 на тарифі Basic недоступний). Файли не в git: `clips/scene{1,2,6,7}.mp4`, решта — у `work/`.

```bash
node record.mjs                     # екрани 3–5 з prototype/index.html#rec → work/rec/
node make-assets.mjs                # тло, рамка телефона, титр, заставка з QR → work/gfx/
python3 ~/.claude/skills/elevenlabs-tts/tts.py озвучка-elevenlabs.txt --scenes -o work/vo/
./build.sh                          # → work/im-clinic-promo.mp4 + .srt
```
Сцени й таймінг — масиви `DUR`/`VO` у `build.sh`. Музика — ElevenLabs Music (інструментал 82 с, промпт нижче), `work/music/bed.mp3`; `build.sh` кладе її під голос на 12–15 dB тихше й притишує на фразах. Ліцензія на комерційне використання — лише на платному тарифі ElevenLabs, перевірити.
Промпт: `Calm, warm, modern corporate background music for a healthcare app commercial. Soft felt piano, light plucked guitar, gentle airy pads, subtle soft percussion entering after 10 seconds, uplifting and reassuring, 90 BPM, major key. Instrumental only.`
YouTube: назва, опис з посиланнями на im.pl.ua/clinic і демо clinic-demo.im.pl.ua, субтитри `im-clinic-promo.srt`, мініатюра.

## Згода й права
- Пацієнтів і лікарів зображуємо тільки згенерованими; реальних людей без письмової згоди не знімаємо.
- Перевірити ліцензію на комерційне використання в тарифі Higgsfield.
- Музика — ElevenLabs Music: комерційне використання дозволене лише на платному тарифі. Перед публікацією перевірити тариф; якщо він безкоштовний — замінити трек на YouTube Audio Library.
- AI-кадри з реалістичними людьми: при завантаженні на YouTube позначити «Змінений або синтетичний контент».
