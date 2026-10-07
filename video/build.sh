#!/usr/bin/env bash
# Монтаж промо IM Clinic → work/im-clinic-promo.mp4 (1920×1080, 30 fps, озвучка ≈ −16 LUFS, пік −1.5 dBFS; ціль loudnorm завищена, бо паузи між фразами тягнуть середнє вниз) + .srt
# Вхід: clips/{pain,reception,relief,qr,scene6,scene7}.mp4 (Higgsfield/Kling), work/rec/*.webm (node record.mjs),
#       work/gfx/*.png (node make-assets.mjs), work/vo/00…10.mp3 (elevenlabs-tts --scenes; 00 — вступ, 10 — заставка).
set -euo pipefail
cd "$(dirname "$0")"
W=work; S=$W/seg; mkdir -p $S
ENC=(-c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r 30 -an)
off() { node -p "require('./$W/rec/offsets.json').$1"; }

# Сцени: 0 — вступ для клінік; 1–9 — шлях пацієнтки за CJM; 10 — заставка з CRM.
# 1 біль · 2 рецепція (запис) · 3 лікування · 4 QR після процедури · 5 застосунок: PIN і всі функції · 6 памʼятка · 7 план · 8 лікар · 9 вулиця
# Тривалість (с) і зсув голосу від початку сцени (с); голос — work/vo/00…10.mp3
DUR=(25.0 6.0 5.0 4.5 7.0 10.5 7.0 7.0 7.0 5.0 14.0)
VO=(0.5 0.6 0.4 0.5 0.6 0.4 0.4 0.6 0.6 0.6 0.5)

# Кліпи Higgsfield/Kling (1912×1080 → 1920×1080); slow > 1 — сповільнення під довшу фразу
clip() { # in out dur slow
  ffmpeg -v error -y -i "$1" -filter_complex "[0:v]setpts=$4*PTS,scale=1920:1080,fps=30,trim=duration=$3" "${ENC[@]}" "$2"; }
clip clips/pain.mp4      $S/1.mp4 6.0 1.2
clip clips/reception.mp4 $S/2.mp4 5.0 1
clip clips/relief.mp4    $S/3.mp4 4.5 1
# Після процедури: Анна сканує QR на рецепції + плашка «IM Clinic · кабінет пацієнта вашої клініки»
ffmpeg -v error -y -i clips/qr.mp4 -loop 1 -i $W/gfx/title.png -filter_complex \
  "[0:v]setpts=1.4*PTS,scale=1920:1080,fps=30,trim=duration=7.0[v];[1:v]format=rgba,fade=in:st=3.0:d=0.5:alpha=1[t];[v][t]overlay=0:0:shortest=1" \
  "${ENC[@]}" $S/4.mp4
clip clips/scene6.mp4    $S/8.mp4 7.0 1.4
clip clips/scene7.mp4    $S/9.mp4 5.0 1

# Екранні сцени: тло з підписом → запис 462×1000 (з 780×1688) → рамка телефона; останній кадр тримається
screen() { # тло запис вихід тривалість
  ffmpeg -v error -y -loop 1 -i $W/gfx/$1.png -i $W/rec/$2.webm -loop 1 -i $W/gfx/frame.png -filter_complex \
    "[1:v]trim=start=$(off $2),setpts=PTS-STARTPTS,fps=30,scale=462:1000:flags=lanczos,tpad=stop_mode=clone:stop_duration=$4[s];\
     [0:v][s]overlay=300:40[a];[a][2:v]overlay=0:0,trim=duration=$4" "${ENC[@]}" $S/$3.mp4; }
screen bgtour  tour  5 10.5
screen bgmemo  memo  6 7.0
screen bgplan  plan  7 7.0

# Вступ (25 с = 6 + 8.4 + 10.6): заставка IM «Вітаємо!» → застосунок клініки → пуш пропозиції й бали
ffmpeg -v error -y -loop 1 -i $W/gfx/intro.png -vf "fps=30,trim=duration=6,fade=in:d=0.6" "${ENC[@]}" $S/0a.mp4
screen bg0b scene0b 0b 8.4; screen bg0c scene0c 0c 10.6

# Кінцева заставка: блок «Для клінік: CRM» — під фразу про інтеграцію (3.7 с), наприкінці в чорне
ffmpeg -v error -y -loop 1 -i $W/gfx/end.png -loop 1 -i $W/gfx/crm.png -filter_complex \
  "[1:v]format=rgba,fade=in:st=3.7:d=0.6:alpha=1[c];[0:v][c]overlay=0:0,fps=30,trim=duration=14,fade=in:d=0.5,fade=out:st=13:d=1" "${ENC[@]}" $S/10.mp4

printf "file '%s'\n" $PWD/$S/{0a,0b,0c,1,2,3,4,5,6,7,8,9,10}.mp4 > $S/list.txt
ffmpeg -v error -y -f concat -safe 0 -i $S/list.txt -c copy $W/video-only.mp4

# Озвучка за таймкодами + субтитри
inputs=(); mix=""; t=0; srt=$W/im-clinic-promo.srt; : > $srt.tmp
LINES=(); while IFS= read -r l; do LINES+=("$l"); done < <(grep -v '^#' озвучка-elevenlabs.txt | grep -v '^СПОСІБ' | grep -v '^──' | sed 's/<break[^>]*>//g;s/  */ /g' | awk 'NF')
for i in {0..10}; do
  n=$(printf %02d $i); f=$W/vo/$n.mp3
  st=$(python3 -c "print($t+${VO[$i]})"); len=$(ffprobe -v error -show_entries format=duration -of csv=p=0 $f)
  inputs+=(-i $f); mix+="[$i:a]adelay=$(python3 -c "print(int($st*1000))"):all=1[a$i];"
  echo "$st|$len|${LINES[$i]}" >> $srt.tmp
  t=$(python3 -c "print($t+${DUR[$i]})")
done
# Субтитри: фраза ріжеться на речення, час ділиться пропорційно довжині речення
python3 - $srt.tmp > $srt <<'PY'
import re,sys
f=lambda s:'%02d:%02d:%02d,%03d'%(s//3600,s%3600//60,s%60,round(s%1*1000))
n=0
for row in open(sys.argv[1],encoding='utf-8'):
    st,ln,txt=row.rstrip('\n').split('|',2); st,ln=float(st),float(ln)
    txt=txt.replace('Ай-Ем Клінік','IM Clinic').replace('Ай-Ем','IM').replace('сі-ар-ем','CRM').replace('кю-ар','QR')  # фонетика лише для синтезу
    parts=re.split(r'(?<=[.!?])\s+',txt.strip()); tot=sum(map(len,parts))
    for p in parts:
        d=ln*len(p)/tot; n+=1; print(f"{n}\n{f(st)} --> {f(st+d)}\n{p}\n"); st+=d
PY
rm $srt.tmp
ffmpeg -v error -y "${inputs[@]}" -filter_complex \
  "${mix}$(printf '[a%d]' {0..10})amix=inputs=11:normalize=0,apad,atrim=duration=$t,loudnorm=I=-11.7:TP=-1.5:LRA=11[a]" \
  -map "[a]" -c:a aac -b:a 192k -ar 48000 $W/voice.m4a
# Музика (work/music/bed.mp3, ElevenLabs Music) — під голосом, притишується на фразах (sidechain)
A=$W/voice.m4a
if [ -f $W/music/bed.mp3 ]; then
  ffmpeg -v error -y -i $W/voice.m4a -i $W/music/bed.mp3 -filter_complex \
    "[0:a]asplit[v][key];[1:a]atrim=duration=$t,volume=-12dB,afade=in:d=1.5,afade=out:st=$(python3 -c "print($t-2.5)"):d=2.5[m];\
     [m][key]sidechaincompress=threshold=0.03:ratio=6:attack=40:release=500[md];\
     [v][md]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=disabled[a]" \
    -map "[a]" -c:a aac -b:a 192k -ar 48000 $W/mix.m4a
  A=$W/mix.m4a
fi
ffmpeg -v error -y -i $W/video-only.mp4 -i $A -c:v copy -c:a copy -shortest -movflags +faststart $W/im-clinic-promo.mp4
echo "готово: $W/im-clinic-promo.mp4 ($t с) і $srt"
