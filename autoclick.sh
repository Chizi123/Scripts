#!/bin/sh

if [ "$(pgrep autoclick | wc -l)" = "2" ]; then 
	true
else
	pkill autoclick 
fi

while :; do
	xdotool click --delay 100 --repeat 10 1
done

