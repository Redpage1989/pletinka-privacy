# Промо-відео IM Clinic: кабінет пацієнта стоматклініки

Формат: YouTube, 16:9 (1920×1080), 88 с (25 с вступу для клінік + 63 с ролика), українська озвучка, субтитри `.srt`.
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
| 0 | 0:00–0:25 | ЗАСТАВКА: «Вітаємо!» → застосунок клініки на телефоні → пуш пропозиції й бали | «Вітаємо! Ми — компанія IM, розробляємо програмне забезпечення. Хочемо представити вам застосунок для пацієнтів вашої клініки…» (повний текст — `озвучка-elevenlabs.txt`, сцена 00) | Вітаємо! · IM Clinic |
| 1 | 0:25–0:30 | HIGGS: героїня Анна вагається біля телефону, дивиться на календар | «Знову забули про візит до стоматолога?» | — |
| 2 | 0:30–0:36 | HIGGS: Анна відкриває посилання від клініки, усміхається | «Тепер усе — у вашому телефоні. IM Clinic: кабінет пацієнта вашої клініки.» | IM Clinic |
| 3 | 0:36–0:45 | ЗАПИС ЕКРАНА: Головна → «Записатися на прийом» → лікар → вільні слоти списком по днях → «Перевірте запис» з полем «що турбує» → «Ви записані» | «Записуйтесь самі: лікар, вільний час, підтвердження. Застосунок показує лише справді вільні години.» | Онлайн-запис |
| 4 | 0:45–0:54 | ЗАПИС ЕКРАНА: пуш «Завтра візит» (клавіша N) → вкладка «Догляд»: памʼятка після видалення, кроки з галочками, червоний блок «коли дзвонити терміново» | «Нагадаємо про візит за добу й за дві години. А після процедури — памʼятка: що робити й коли дзвонити терміново.» | Нагадування й памʼятки |
| 5 | 0:54–1:02 | ЗАПИС ЕКРАНА: «Лікування»: залишок 40 650 ₴ → зубна формула → етапи з цінами → «що буде, якщо чекати» → розстрочка → «Погодити план» | «План лікування з етапами й сумами — і погодити його можна просто в телефоні.» | План лікування |
| 6 | 1:02–1:09 | HIGGS: лікар у кабінеті показує пацієнтці план лікування на планшеті | «Лікар пояснює план своїми словами, а він лишається у вас — з етапами й цінами.» | — |
| 7 | 1:09–1:14 | HIGGS: Анна виходить з клініки, усміхнена, на вулиці | «Піклуйтеся про посмішку зручно.» | — |
| 8 | 1:14–1:28 | Знак IM + «IM Clinic» на тлі `#0A151D`, QR на im.pl.ua/clinic | «Попросіть посилання на рецепції своєї клініки. А для клінік: адміністративна частина інтегрується з вашою CRM — швидко й безпечно. Посилання — в описі.» (блок «Для клінік: CRM» з 3,7 с) | im.pl.ua/clinic |

Функції в кадрах 3–5 звірено з кодом застосунку (PureApp) і уроком `clinic.mp4`. Не обіцяти: онлайн-оплату, чат, знімки в застосунку, App Store / Google Play (це PWA, ставиться з браузера).

## Промпти для Higgsfield (англійською — так стабільніше)

Стиль для всіх: `bright modern dental clinic, soft natural daylight, clean white and deep blue (#1B4D9E) palette, cinematic shallow depth of field, warm and reassuring mood, 16:9`

**Героїня (референс, спершу картинка):**
`Portrait of a friendly Ukrainian woman, 32 years old, shoulder-length light-brown hair, casual beige cardigan, natural smile, soft window light, neutral background, photorealistic`

**Кадр 1:** `Same woman sits on a sofa at home holding a smartphone, looks slightly worried, glances at a wall calendar, slow push-in, soft daylight, photorealistic`

**Кадр 2:** `Same woman looks at the phone screen and smiles with relief, subtle head movement, shallow depth of field, phone screen not visible to camera, slow dolly in`

**Кадр 6:** `Friendly female dentist in white coat shows a tablet to a smiling patient in a modern dental office, over-the-shoulder shot, gentle camera move, tablet screen out of focus`

**Кадр 7:** `Same woman walks out of a modern clinic entrance into a sunny street, confident natural smile, light breeze in hair, tracking shot from the front, photorealistic`

Негатив/уникати: текст на екранах, логотипи, зуби крупним планом із дефектами, надмірно «ідеальні» голлівудські зуби.

## Збірка (зроблено 06.10.2026, ролик 88 с)
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
