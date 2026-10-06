#!/usr/bin/env bash
# GIF-прев'ю промо для листів (im-outreach: products/im-clinic.yaml → animated:) → work/clinic-promo.gif
# 5,2 с ключових моментів (рецепція з QR → візит у телефоні → полегшення) з кнопкою ▶, 360×203, 5 fps,
# 32 кольори ≈ 280 КБ: лист разом з картинками ~480 КБ. Gmail і Apple Mail грають GIF, Outlook показує 1-й кадр.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
from PIL import Image, ImageDraw
W, H = 360, 203; im = Image.new('RGBA', (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
r, cx, cy = 25, W // 2, H // 2
d.ellipse((cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2), fill=(255, 255, 255, 90))
d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(10, 102, 221, 235))
d.polygon([(cx - 8, cy - 12), (cx - 8, cy + 12), (cx + 14, cy)], fill=(255, 255, 255, 255))
im.save('work/play360.png')
PY
ffmpeg -v error -y -i work/im-clinic-promo.mp4 -loop 1 -i work/play360.png -filter_complex \
  "[0:v]trim=32.2:34.2,setpts=PTS-STARTPTS[a];[0:v]trim=42.2:44.0,setpts=PTS-STARTPTS[b];[0:v]trim=49.0:50.4,setpts=PTS-STARTPTS[c];\
   [a][b][c]concat=n=3,fps=5,scale=w=360:h=203:flags=lanczos[v];[1:v]format=rgba[pb];[v][pb]overlay=0:0:shortest=1,split[s0][s1];\
   [s0]palettegen=max_colors=32:stats_mode=diff[p];[s1][p]paletteuse=dither=none:diff_mode=rectangle" -loop 0 work/clinic-promo.gif
ls -la work/clinic-promo.gif
