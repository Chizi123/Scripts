#!/bin/bash

# Script to transcode music in buld using ffmpeg

bitrate=192

transcode() {
	if [ "ffprobe $1 2>&1 | grep bitrate | cut -d' ' -f8" > 192000 ]; then
		echo in $1
		echo out "trans_music/$(echo ${1%.*} | cut -f1 -d'/' --complement).mp3"
		ffmpeg -i "$d" -b:a $bitrate "trans_music/$(echo ${1%.*}).mp3"#| cut -f1 -d'/' --complement).mp3"
	else
		cp "$d" "trans_music/$(echo $1)" # | cut -f1 -d'/' --complement)"
	fi
}

shopt -s globstar

rm -r trans_music
mkdir trans_music

cp -r --attributes-only Music/* trans_music/
find trans_music -type f -delete
for d in **/*.{mp3,flac,mp4,m4a,ogg}; do
	transcode $d &
done
