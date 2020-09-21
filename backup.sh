#!/bin/sh

BACKUP_DIR="/backup/work/"
FILES_DIR="/home/joel/OneDrive/"
RCLONE_BACKUP=("GoogleDrive" "Mega" "unimelb" "pCloud" "gdrive_unimelb" "NC_home" "NextCloud")
RCLONE_FILES=("Mega" "unimelb" "gdrive_unimelb" "NC_home")

function sync() {
	case $1 in
		"sout")
			rclone sync $([ $2 != "p" ] && echo "$BACKUP_DIR" || echo "$FILES_DIR") \
				   $1:/data/Cloud/$([ $2 != "p" ] && echo "backup" || echo "files") $(! [ -z $3 ] && echo "-P")
			;;
		*)
			rclone sync $([ $2 != "p" ] && echo "$BACKUP_DIR" || echo "$FILES_DIR") \
				   $1:/Uni/$([ $2 != "p" ] && echo "borg" || echo "files")  $(! [ -z $3 ] && echo "-P")
			;;
	esac
}

function sync_all() {
	if [ -z $1 ]; then
		for i in ${RCLONE_BACKUP[*]}; do
			#echo -e '\033[0;31m'$i backup'\033[0m'
			sync $i n &
		done
		for i in ${RCLONE_FILES[*]}; do
			#echo -e '\033[0;31m'$i files'\033[0m'
			sync $i p &
		done
	else
		for i in ${RCLONE_BACKUP[*]}; do
			echo -e '\033[0;31m'$i backup'\033[0m'
			sync $i n p
		done
		for i in ${RCLONE_FILES[*]}; do
			echo -e '\033[0;31m'$i files'\033[0m'
			sync $i p p
		done
	fi
}

cd /home/joel/OneDrive

if [ "$1" = "sync" ]; then
	echo -e '\033[0;32m'Syncing'\033[0m'
	sync_all p
	exit
elif [ "$1" = "cron" ]; then
	borg create \
	 --compression zstd,22 \
	 --exclude '*~' \
	 --exclude '*#*' \
	 \
	 $BACKUP_DIR::"$(date +%F+%R)" \
	 $FILES_DIR
else
	borg create \
	 --verbose \
	 --stats \
	 --compression zstd,22 \
	 --exclude '*~' \
	 --exclude '*#*' \
	 \
	 $BACKUP_DIR::"$(date +%F+%R)" \
	 $FILES_DIR
fi

borg prune \
	 --keep-hourly 12 \
	 --keep-daily 8 \
	 --keep-monthly 2 \
	 $BACKUP_DIR

LAST="$(borg list $BACKUP_DIR | tail -n2 | cut -d' ' -f1)"
if [ -z "$(borg diff $BACKUP_DIR::$(echo $LAST | cut -d' ' -f1) $(echo $LAST | cut -d' ' -f2))" ]; then
	borg delete $BACKUP_DIR::$(echo $LAST | cut -d' ' -f2)
else
	echo "New backup $(echo $LAST | cut -d' ' -f2)"
	sync_all
fi
