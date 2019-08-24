#!/bin/sh
server_port=8000
ip_address=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
pulse_source=$(pactl list sources short | grep analog-stereo.monitor | awk '{print $2}')
case "$1" in
  start)
    $0 stop 
    pactl load-module module-simple-protocol-tcp rate=48000 format=s16le channels=2 source=$pulse_source record=true port=$server_port
    ;;
  stop)
    pactl unload-module `pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g'`
    ;;
  *)
    echo "Usage: $0 start|stop" >&2
    ;;
esac
