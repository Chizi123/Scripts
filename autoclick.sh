#!/bin/sh

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
	TOOL=ydotool
else
	TOOL=xdotool
fi

if [ "$(pgrep autoclick | wc -l)" = "2" ]; then 
	true
else
	pkill autoclick 
fi

while :; do
	$TOOL click 1
	sleep 0.1
done

