#!/bin/bash

if [ "$1" = "pull" ]; then
	rclone sync GoogleDrive:/Database.kdbx /tmp/
elif [ "$1" = "push" ]; then
	rclone sync /tmp/Database.kdbx GoogleDrive:/
	rm -rf /tmp/Database.kdbx
else
	echo "Usage: $0 pull|push"
	exit 1
fi
