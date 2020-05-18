#!/bin/sh

BACKUP_DIR="/backup/work/"
FILES_DIR="/home/joel/OneDrive/"
RCLONE_BACKUP=("OneDrive_Personal" "NextCloud" "GoogleDrive" "Mega" "unimelb" "sout" "pCloud")
RCLONE_FILES=("sout" "Mega" "unimelb")

function sync() {
	if [ $2 != "p" ]; then
		case $1 in
			"sout")
				rclone sync $BACKUP_DIR $1:/data/Cloud/backup $(! [ -z $3 ] && echo "-P")
				;;
			*)
				rclone sync $BACKUP_DIR $1:/Uni/duplicacy  $(! [ -z $3 ] && echo "-P")
				;;
		esac
	else
		case $1 in
			"sout")
				rclone sync $FILES_DIR $1:/data/Cloud/files  $(! [ -z $3 ] && echo "-P")
				;;
			*)
				rclone sync $FILES_DIR $1:/Uni/files  $(! [ -z $3 ] && echo "-P")
				;;
			esac
	fi
}

function sync_all() {
	if [ -z $1 ]; then
		for i in ${RCLONE_BACKUP[*]}; do
			sync $i &
		done
		for i in ${RCLONE_FILES[*]}; do
			sync $i p &
		done
	else
		for i in ${RCLONE_BACKUP[*]}; do
			echo -e '\033[0;31m'$i backup'\033[0m'
			sync $i n p
		done
		for i in ${RCLONE_FILES[*]}; do
			echo '\033[0;31m'$i files'\033[0m'
			sync $i p p
		done
	fi
}

cd /home/joel/OneDrive

if [ "$1" = "sync" ]; then
	echo -e '\033[0;32m'Syncing'\033[0m'
	sync_all p
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

duplicacy prune -keep 7:30 -keep 1:7 -exclusive > /dev/null 2>&1

if [ -z "$DIFF" ]; then
	duplicacy prune -r $CURR -exclusive > /dev/null 2>&1
else
	echo "New backup $CURR"
	sync_all
fi
