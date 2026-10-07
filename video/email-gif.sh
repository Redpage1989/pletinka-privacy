#!/usr/bin/env bash
# GIF-прев'ю промо для листів (im-outreach: products/im-clinic.yaml → animated:) → work/clinic-promo.gif
# 5,2 с ключових моментів (QR на планшеті → застосунок з пушем → усмішка) з кнопкою ▶ у правому нижньому куті, 360×203, 5 fps,
# ≤ 290 КБ: лист разом з картинками ~480 КБ. Gmail і Apple Mail грають GIF, Outlook показує 1-й кадр.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
from PIL import Image, ImageDraw
W, H = 360, 203; im = Image.new('RGBA', (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
r = 22; cx, cy = W - r - 14, H - r - 14  # ▶ у правому нижньому куті: по центру закривала QR, заголовок і усмішку Анни
d.ellipse((cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2), fill=(255, 255, 255, 90))
d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(10, 102, 221, 235))
d.polygon([(cx - 7, cy - 11), (cx - 7, cy + 11), (cx + 12, cy)], fill=(255, 255, 255, 255))
im.save('work/play360.png')
PY
# Таймкоди — під монтаж 98 с (build.sh): QR на планшеті з плашкою IM Clinic (сцена 4: 40,5–47,5 с) →
# застосунок після PIN: головна з пушем «Завтра візит» (сцена 5: 47,5–58 с) → щаслива усмішка на вулиці (сцена 9: 79–84 с).
# Палітра 32→24→16 кольорів, доки GIF не стане ≤ 290 КБ (у фото-сценах 32 кольори дають ~400 КБ).
for C in 32 24 16; do
  ffmpeg -v error -y -i work/im-clinic-promo.mp4 -loop 1 -i work/play360.png -filter_complex \
    "[0:v]trim=43.6:45.6,setpts=PTS-STARTPTS[a];[0:v]trim=51.5:53.3,setpts=PTS-STARTPTS[b];[0:v]trim=81.6:83.0,setpts=PTS-STARTPTS[c];\
     [a][b][c]concat=n=3,fps=5,scale=w=360:h=203:flags=lanczos[v];[1:v]format=rgba[pb];[v][pb]overlay=0:0:shortest=1,split[s0][s1];\
     [s0]palettegen=max_colors=$C:stats_mode=diff[p];[s1][p]paletteuse=dither=none:diff_mode=rectangle" -loop 0 work/clinic-promo.gif
  [ "$(wc -c < work/clinic-promo.gif)" -le 296960 ] && break
done
echo "кольорів: $C"; ls -la work/clinic-promo.gif
