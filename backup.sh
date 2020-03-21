#!/bin/sh

cd /home/joel/OneDrive

if [ $1 == "sync" ]; then
	echo Syncing
	BACKUP_DIR="/backup/work/"
	echo OneDrive Personal
	rclone sync $BACKUP_DIR "OneDrive_Personal":/Uni -P
	echo NextCloud
	rclone sync $BACKUP_DIR "NextCloud":/Uni -P
	echo GoogleDrive
	rclone sync $BACKUP_DIR "GoogleDrive":/Uni -P
	echo Mega
	rclone sync $BACKUP_DIR "Mega":/Uni -P
	echo unimelb
	rclone sync $BACKUP_DIR "unimelb":/ -P
	echo sout
	rclone sync $BACKUP_DIR "sout":/data/Cloud -P
	exit
fi

LAST="$(duplicacy list | tail -n1 | cut -d' '  -f4)"
CURR="$(duplicacy backup | tail -n1 | sed 's/[^0-9]//g')"
#LAST=2
#CURR=4
DIFF="$(duplicacy diff -r $CURR -r $LAST | grep '-')"

#echo "curr - $CURR"
#echo "last - $LAST"
#echo "diff - $DIFF"

duplicacy prune -keep 1:7 -keep 7:30 -exclusive > /dev/null 2>&1

if [ -z "$DIFF" ]; then
	duplicacy prune -r $CURR -exclusive > /dev/null 2>&1
else
	echo "New backup $CURR"
	BACKUP_DIR="/backup/work/"
	rclone sync $BACKUP_DIR "OneDrive_Personal":/Uni &
	rclone sync $BACKUP_DIR "NextCloud":/Uni &
	rclone sync $BACKUP_DIR "GoogleDrive":/Uni &
	rclone sync $BACKUP_DIR "Mega":/Uni &
	rclone sync $BACKUP_DIR "unimelb":/ &
	rclone sync $BACKUP_DIR "sout":/data/Cloud &
	#rclone sync $BACKUP_DIR "Oracle":/Uni
fi
