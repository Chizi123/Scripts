#!/bin/bash

# Script to transcode music in buld using ffmpeg

bitrate=192000

shopt -s globstar

rm -r trans_music
mkdir trans_music

cp -r --attributes-only Music/* trans_music/
find trans_music -type f -delete
for d in **/*.{mp3,flac,mp4,m4a,ogg}; do
	if [ "ffprobe -show_format 2>/dev/null $d | grep bit_rate | cut -d'=' -f2" > 192000 ]; then
		echo in $d
		echo out "trans_music/$(echo ${d%.*} | cut -f1 -d'/' --complement).mp3"
		ffmpeg -i "$d" -b:a $bitrate "trans_music/$(echo ${d%.*} | cut -f1 -d'/' --complement).mp3"
	else
		cp "$d" "trans_music/$(echo $d | cut -f1 -d'/' --complement)"
	fi
done
