#!/bin/bash

shopt -s globstar

rm -r trans_music
mkdir trans_music

cp -r --attributes-only Music/* trans_music/
find trans_music -type f -delete
for d in **/*.{mp3,flac,mp4,m4a,ogg}; do
	if [ "ffprobe -show_format 2>/dev/null $d | grep bit_rate | cut -d'=' -f2" > 192000 ]; then
		echo in $d
		echo out "trans_music/$(echo ${d%.*} | cut -f2,3,4,5 -d'/').mp3"
		ffmpeg -i "$d" -b:a 192000 "trans_music/$(echo $d | cut -f1 -d'.' | cut -f2,3,4,5 -d'/').mp3"
	else
		cp "$d" "trans_music/$(echo $d | cut -f2,3,4,5 -d'/')"
	fi
done
