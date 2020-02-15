#!/bin/sh

cd /home/joel/OneDrive

LAST="$(duplicacy list | tail -n1 | cut -d' '  -f4)"
CURR="$(duplicacy backup | grep "revision [0-9] completed" | sed 's/[^0-9]//g')"
#LAST=2
#CURR=4
DIFF="$(duplicacy diff -r $CURR -r $LAST | grep '-')"

#echo "curr - $CURR"
#echo "last - $LAST"
#echo "diff - $DIFF"

if [ -z "$DIFF" ]; then
	duplicacy prune -r $CURR -exclusive
else
	echo "No diff to backup"
fi
duplicacy prune -keep 1:7 -keep 7:30 -exclusive

BACKUP_DIR="/backup/work/"
rclone sync $BACKUP_DIR "OneDrive_Personal":/Uni &
rclone sync $BACKUP_DIR "NextCloud":/Uni &
rclone sync $BACKUP_DIR "GoogleDrive":/Uni &
rclone sync $BACKUP_DIR "Mega":/Uni &
rclone sync $BACKUP_DIR "unimelb":/ &
rclone sync $BACKUP_DIR "sout":/data/Cloud &
#rclone sync $BACKUP_DIR "Oracle":/Uni
