#!/usr/bin/env bash
# Монтаж промо IM Clinic → work/im-clinic-promo.mp4 (1920×1080, 30 fps, озвучка ≈ −16 LUFS, пік −1.5 dBFS; ціль loudnorm завищена, бо паузи між фразами тягнуть середнє вниз) + .srt
# Вхід: clips/scene{1,2,6,7}.mp4 (Higgsfield/Kling), work/rec/*.webm (node record.mjs),
#       work/gfx/*.png (node make-assets.mjs), work/vo/0N.mp3 (elevenlabs-tts --scenes).
set -euo pipefail
cd "$(dirname "$0")"
W=work; S=$W/seg; mkdir -p $S
ENC=(-c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r 30 -an)
off() { node -p "require('./$W/rec/offsets.json').$1"; }

# Сцена: тривалість (с) і зсув голосу від початку сцени (с)
DUR=(5.0 6.5 8.5 9.0 8.5 6.5 5.0 7.0)
VO=(0.6 0.4 0.4 0.3 0.5 0.4 0.8 0.5)

# Кліпи Higgsfield. 1912×1080 → 1920×1080 (різниця 0,4 %). Сцени 2 і 6 сповільнено ×1.3 під довшу фразу.
clip() { # in out dur slow [extra-filter]
  ffmpeg -v error -y -i "$1" -filter_complex "[0:v]setpts=$4*PTS,scale=1920:1080,fps=30,trim=duration=$3${5:+,$5}" "${ENC[@]}" "$2"; }
clip clips/scene1.mp4 $S/1.mp4 5.0 1
ffmpeg -v error -y -i clips/scene2.mp4 -loop 1 -i $W/gfx/title.png -filter_complex \
  "[0:v]setpts=1.3*PTS,scale=1920:1080,fps=30,trim=duration=6.5[v];[1:v]format=rgba,fade=in:st=1.2:d=0.5:alpha=1[t];[v][t]overlay=0:0:shortest=1" \
  "${ENC[@]}" $S/2.mp4
clip clips/scene6.mp4 $S/6.mp4 6.5 1.3
clip clips/scene7.mp4 $S/7.mp4 5.0 1

# Екранні сцени: тло → запис 462×1000 (з 780×1688) → рамка телефона; останній кадр тримається до кінця сцени
screen() { # n dur
  ffmpeg -v error -y -loop 1 -i $W/gfx/bg$1.png -i $W/rec/scene$1.webm -loop 1 -i $W/gfx/frame.png -filter_complex \
    "[1:v]trim=start=$(off scene$1),setpts=PTS-STARTPTS,fps=30,scale=462:1000:flags=lanczos,tpad=stop_mode=clone:stop_duration=$2[s];\
     [0:v][s]overlay=300:40[a];[a][2:v]overlay=0:0,trim=duration=$2" "${ENC[@]}" $S/$1.mp4; }
screen 3 8.5; screen 4 9.0; screen 5 8.5

# Кінцева заставка: проявляється й іде в чорне
ffmpeg -v error -y -loop 1 -i $W/gfx/end.png -vf "fps=30,trim=duration=7,fade=in:d=0.5,fade=out:st=6:d=1" "${ENC[@]}" $S/8.mp4

printf "file '%s'\n" $PWD/$S/{1..8}.mp4 > $S/list.txt
ffmpeg -v error -y -f concat -safe 0 -i $S/list.txt -c copy $W/video-only.mp4

# Озвучка за таймкодами + субтитри
inputs=(); mix=""; t=0; srt=$W/im-clinic-promo.srt; : > $srt
LINES=(); while IFS= read -r l; do LINES+=("$l"); done < <(grep -v '^#' озвучка-elevenlabs.txt | grep -v '^СПОСІБ' | sed 's/<break[^>]*>//g;s/  */ /g' | awk 'NF')
fmt() { python3 -c "s=$1;print('%02d:%02d:%02d,%03d'%(s//3600,s%3600//60,s%60,round(s%1*1000)))"; }
for i in {0..7}; do
  n=$(printf %02d $((i+1))); f=$W/vo/$n.mp3
  st=$(python3 -c "print($t+${VO[$i]})"); len=$(ffprobe -v error -show_entries format=duration -of csv=p=0 $f)
  inputs+=(-i $f); mix+="[$i:a]adelay=$(python3 -c "print(int($st*1000))"):all=1[a$i];"
  printf "%d\n%s --> %s\n%s\n\n" $((i+1)) "$(fmt $st)" "$(fmt "$st+$len")" "${LINES[$i]}" >> $srt
  t=$(python3 -c "print($t+${DUR[$i]})")
done
ffmpeg -v error -y "${inputs[@]}" -filter_complex \
  "${mix}$(printf '[a%d]' {0..7})amix=inputs=8:normalize=0,apad,atrim=duration=$t,loudnorm=I=-11.7:TP=-1.5:LRA=11[a]" \
  -map "[a]" -c:a aac -b:a 192k -ar 48000 $W/voice.m4a
ffmpeg -v error -y -i $W/video-only.mp4 -i $W/voice.m4a -c:v copy -c:a copy -shortest -movflags +faststart $W/im-clinic-promo.mp4
echo "готово: $W/im-clinic-promo.mp4 ($t с) і $srt"
