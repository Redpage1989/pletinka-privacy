#!/usr/bin/env bash
# Музика під готові відеоуроки IM Clinic (пацієнт і адмінка) → work/tutorials/{clinic,clinic-admin}.mp4
# Відео береться з опублікованої web-копії без перекодування, голос — з майстра (192 кбіт/с),
# музика — ElevenLabs Music під довжину уроку (work/music/bed-{patient,admin}.mp3),
# на −15 dB і з притишенням на фразах (sidechain). Готові файли — заміна для im-site/public/video/.
set -euo pipefail
cd "$(dirname "$0")"
V=${PUREAPP:-$HOME/Developer/PureApp}/scripts/video
mkdir -p work/tutorials
mix() { # музика  майстер-без-.mp4  вихід
  local src=$V/$2 d; d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$src.mp4")
  ffmpeg -v error -y -i "$src-web.mp4" -i "$src.mp4" -i work/music/bed-$1.mp3 -filter_complex \
    "[1:a]asplit[v][key];[2:a]atrim=duration=$d,volume=-15dB,afade=in:d=2,afade=out:st=$(python3 -c "print($d-3)"):d=3[m];\
     [m][key]sidechaincompress=threshold=0.03:ratio=6:attack=40:release=600[md];\
     [v][md]amix=inputs=2:normalize=0,alimiter=limit=0.8:level=disabled[a]" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 128k -ar 48000 -movflags +faststart work/tutorials/$3.mp4
  echo "work/tutorials/$3.mp4"
}
mix patient tutorial-patient/work/clinic-patient-tutorial clinic
mix admin tutorial-admin/work/clinic-admin-tutorial clinic-admin
